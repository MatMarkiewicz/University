import argparse
import tensorflow as tf
import tensorflow_model_optimization as tfmot
from pathlib import Path
from typing import Optional

from dl_in_iot_course.misc.pet_dataset import PetDataset
from dl_in_iot_course.l02_quantization.quantization_experiments\
    import FP32Model


class TFMOTOptimizedModel(FP32Model):

    def compress_and_fine_tune(self, originalmodel: Path):
        """
        Runs selected compression algorithm and fine-tunes the model.

        This method wraps the usage of TensorFlow Model Optimization Toolkit
        optimization, fine-tunes the model, convert it to TensorFlow Lite and
        saves the model to self.modelpath file.

        All structures required for training are delivered to self object by
        the optimize_model method.

        Parameters
        ----------
        originalmodel : Path
            Path to the original model
        """
        pass

    def optimize_model(self, originalmodel: Path):
        def preprocess_input(path, onehot):
            data = tf.io.read_file(path)
            img = tf.io.decode_jpeg(data, channels=3)
            img = tf.image.resize(img, [224, 224])
            img = tf.image.convert_image_dtype(img, dtype=tf.float32)
            img /= 255.0
            img = tf.image.random_brightness(img, 0.1)
            img = tf.image.random_contrast(img, 0.7, 1.0)
            img = tf.image.random_flip_left_right(img)
            img = (img - self.dataset.mean) / self.dataset.std
            return img, tf.convert_to_tensor(onehot)

        self.batch_size = 8
        self.learning_rate = 0.00001
        self.epochs = 1
        Xt, Xv, Yt, Yv = self.dataset.split_dataset(
            0.4
        )
        Yt = list(self.dataset.onehotvectors[Yt])
        Yv = list(self.dataset.onehotvectors[Yv])

        # TensorFlow Dataset object for training
        self.traindataset = tf.data.Dataset.from_tensor_slices((Xt, Yt)).map(
            preprocess_input,
            num_parallel_calls=tf.data.experimental.AUTOTUNE
        ).batch(self.batch_size)

        # TensorFlow Dataset object for validation
        self.validdataset = tf.data.Dataset.from_tensor_slices((Xv, Yv)).map(
            preprocess_input,
            num_parallel_calls=tf.data.experimental.AUTOTUNE
        ).batch(self.batch_size)

        # loss function
        self.loss = tf.keras.losses.CategoricalCrossentropy(from_logits=True)

        # Adam optimizer
        self.optimizer = tf.keras.optimizers.Adam(
            learning_rate=self.learning_rate
        )

        # Categorical accuracy metric
        self.metrics = [tf.keras.metrics.CategoricalAccuracy()]

        # method to implement
        self.compress_and_fine_tune(originalmodel)


class ClusteredModel(TFMOTOptimizedModel):
    """
    This tester tests the performance of the clustered model.
    """
    def __init__(
            self,
            dataset: PetDataset,
            modelpath: Path,
            originalmodel: Optional[Path] = None,
            logdir: Optional[Path] = None,
            num_clusters: int = 16):
        """
        Initializer for ClusteredModel.

        ClusteredModel runs model clustering with defined number of clusters
        per layer.

        Parameters
        ----------
        dataset : PetDataset
            A dataset object to test on
        modelpath : Path
            Path to the model to test
        originalmodel : Path
            Path to the model to optimize before testing.
            Optimized model will be saved in modelpath
        logdir : Path
            Path to the training/optimization logs
        num_clusters : int
            Number of clusters per layer
        """
        self.num_clusters = num_clusters
        super().__init__(dataset, modelpath, originalmodel, logdir)

    def compress_and_fine_tune(self, originalmodel):
        cluster_weights = tfmot.clustering.keras.cluster_weights
        CentroidInitialization = tfmot.clustering.keras.CentroidInitialization

        clustering_params = {
            'number_of_clusters': self.num_clusters,
            'cluster_centroids_init': CentroidInitialization.LINEAR
        }

        model = tf.keras.models.load_model(str(originalmodel))

        clustered_model = cluster_weights(model, **clustering_params)
        clustered_model.compile(
            loss=self.loss,
            optimizer=self.optimizer,
            metrics=self.metrics)
        clustered_model.fit(
            self.traindataset,
            epochs=self.epochs,
            validation_data=self.validdataset)

        final_model = tfmot.clustering.keras.strip_clustering(clustered_model)
        converter = tf.lite.TFLiteConverter.from_keras_model(final_model)
        tflite_clustered_model = converter.convert()

        with open(self.modelpath, 'wb') as f:
            f.write(tflite_clustered_model)


class PrunedModel(TFMOTOptimizedModel):
    """
    This tester tests the performance of the pruned model.
    """
    def __init__(
            self,
            dataset: PetDataset,
            modelpath: Path,
            originalmodel: Optional[Path] = None,
            logdir: Optional[Path] = None,
            target_sparsity: float = 0.3):
        """
        Initializer for PrunedModel.

        PrunedModel performs level pruning to a specified target sparsity.

        Parameters
        ----------
        dataset : PetDataset
            A dataset object to test on
        modelpath : Path
            Path to the model to test
        originalmodel : Path
            Path to the model to optimize before testing.
            Optimized model will be saved in modelpath
        logdir : Path
            Path to the training/optimization logs
        target_sparsity : float
            The target sparsity of the model
        """
        self.target_sparsity = target_sparsity
        super().__init__(dataset, modelpath, originalmodel, logdir)

    def compress_and_fine_tune(self, originalmodel):
        self.epochs = 4
        self.sched = tfmot.sparsity.keras.ConstantSparsity(
            self.target_sparsity,
            begin_step=0,
            end_step=1,
            frequency=1)

        model = tf.keras.models.load_model(str(originalmodel))

        prune_low_magnitude = tfmot.sparsity.keras.prune_low_magnitude
        model_for_pruning = prune_low_magnitude(model, self.sched)
        model_for_pruning.compile(
            optimizer=self.optimizer,
            loss=self.loss,
            metrics=self.metrics)
        callbacks = [tfmot.sparsity.keras.UpdatePruningStep()]
        model_for_pruning.fit(
            self.traindataset,
            epochs=self.epochs,
            validation_data=self.validdataset,
            callbacks=callbacks)

        final_model = tfmot.sparsity.keras.strip_pruning(model_for_pruning)
        converter = tf.lite.TFLiteConverter.from_keras_model(final_model)
        tflite_pruned_model = converter.convert()

        with open(self.modelpath, 'wb') as f:
            f.write(tflite_pruned_model)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--model-path',
        help='Path to the model file',
        type=Path
    )
    parser.add_argument(
        '--dataset-root',
        help='Path to the dataset file',
        type=Path
    )
    parser.add_argument(
        '--download-dataset',
        help='Download the dataset before training',
        action='store_true'
    )
    parser.add_argument(
        '--results-path',
        help='Path to the results',
        type=Path
    )
    parser.add_argument(
        '--test-dataset-fraction',
        help='What fraction of the test dataset should be used for evaluation',
        type=float,
        default=1.0
    )

    args = parser.parse_args()

    args.results_path.mkdir(parents=True, exist_ok=True)

    dataset = PetDataset(args.dataset_root, args.download_dataset)

    for num_clusters in [2, 4, 8, 16, 32]:
        # test of the model executed with FP32 precision
        tester = ClusteredModel(
            dataset,
            args.results_path / f'{args.model_path.stem}.clustered-{num_clusters}.tflite',  # noqa: E501
            args.model_path,
            args.results_path / f'clusterlog-{num_clusters}',
            num_clusters
        )
        tester.test_inference(
            args.results_path,
            f'clustered-{num_clusters}-fp32',
            args.test_dataset_fraction
        )

    for sparsity in [0.2, 0.4, 0.5]:
        # test of the model executed with FP32 precision
        tester = PrunedModel(
            dataset,
            args.results_path / f'{args.model_path.stem}.pruned-{sparsity}.tflite',  # noqa: E501
            args.model_path,
            args.results_path / f'prunelog-{sparsity}',
            sparsity
        )
        tester.test_inference(
            args.results_path,
            f'pruned-{sparsity}-fp32',
            args.test_dataset_fraction
        )
