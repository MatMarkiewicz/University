import argparse
import numpy as np
import tensorflow as tf
from pathlib import Path
from tqdm import tqdm
from typing import Optional

from dl_in_iot_course.misc.pet_dataset import PetDataset
from dl_in_iot_course.misc.modeltester import ModelTester


class NativeModel(ModelTester):
    """
    Tests the performance of the model ran natively with TensorFlow.
    This tester verifies the work of the native TensorFlow model without any
    optimizations.
    """
    def prepare_model(self):
        self.model = tf.keras.models.load_model(str(self.modelpath))
        self.model.summary()

    def preprocess_input(self, X):
        self.X = X

    def run_inference(self):
        return self.model.predict(self.X)


class FP32Model(ModelTester):
    """
    This tester tests the performance of FP32 TensorFlow Lite model.
    """
    def optimize_model(self, originalmodel: Path):
        orgmodel = tf.keras.models.load_model(str(originalmodel))
        converter = tf.lite.TFLiteConverter.from_keras_model(orgmodel)
        tflite_model = converter.convert()
        with open(self.modelpath, 'wb') as f:
            f.write(tflite_model)

    def prepare_model(self):
        self.model = tf.lite.Interpreter(
            model_path=str(self.modelpath),
            num_threads=4
        )
        self.model.allocate_tensors()

    def preprocess_input(self, X):
        # since we only want to measure inference time, not tensor allocation,
        # we mode setting tensor to preprocess_input
        self.model.set_tensor(self.model.get_input_details()[0]['index'], X)

    def run_inference(self):
        self.model.invoke()

    def postprocess_outputs(self, Y):
        output_details = self.model.get_output_details()[0]['index']
        return self.model.get_tensor(output_details)


class INT8Model(ModelTester):
    """
    This tester tests the performance of INT8Model TensorFlow Lite model.
    """
    def __init__(
            self,
            dataset: PetDataset,
            modelpath: Path,
            originalmodel: Optional[Path] = None,
            calibrationdatasetpercent: float = 0.5):
        """
        Initializer for INT8Model.
        Parameters
        ----------
        dataset : PetDataset
            A dataset object to test on
        modelpath : Path
            Path to the model to test
        originalmodel : Path
            Path to the model to optimize before testing.
            Optimized model will be saved in modelpath
        calibrationdatasetpercent : float
            Tells the percentage of train dataset used for calibration process
        """

        self.calibrationdatasetpercent = calibrationdatasetpercent

        super().__init__(dataset, modelpath, originalmodel)

    def calibration_dataset_generator(self):
        return self.dataset.calibration_dataset_generator(
            self.calibrationdatasetpercent,
            1234
        )

    def optimize_model(self, originalmodel: Path):
        orgmodel = tf.keras.models.load_model(str(originalmodel))
        converter = tf.lite.TFLiteConverter.from_keras_model(orgmodel)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.representative_dataset = self.calibration_dataset_generator
        supported_ops = tf.lite.OpsSet.TFLITE_BUILTINS_INT8
        converter.target_spec.supported_ops = [supported_ops]
        converter.inference_input_type = tf.int8
        converter.inference_output_type = tf.int8
        tflite_model = converter.convert()
        with open(self.modelpath, 'wb') as f:
            f.write(tflite_model)

    def prepare_model(self):
        self.model = tf.lite.Interpreter(
            model_path=str(self.modelpath),
            num_threads=4
        )
        self.model.allocate_tensors()

    def preprocess_input(self, X):
        input_details = self.model.get_input_details()[0]
        input_scale, input_zero_point = input_details['quantization']
        X = X / input_scale + input_zero_point
        X = X.astype(input_details["dtype"])
        self.model.set_tensor(input_details['index'], X)

    def run_inference(self):
        self.model.invoke()

    def postprocess_outputs(self, Y):
        output_details = self.model.get_output_details()[0]
        output_scale, output_zero_point = output_details['quantization']
        Y = self.model.get_tensor(self.model.get_output_details()[0]['index'])
        Y = (Y - output_zero_point) * output_scale
        return Y


class ImbalancedINT8Model(INT8Model):
    def calibration_dataset_generator(self):
        X, Y = np.array(self.dataset.dataX), np.array(self.dataset.dataY)
        for x in tqdm(X[Y == 5], desc='calibration'):
            yield [self.dataset.prepare_input_sample(x)]


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

    # test of the model executed natively
    tester = NativeModel(dataset, args.model_path)
    tester.prepare_model()
    tester.test_inference(
        args.results_path,
        'native',
        args.test_dataset_fraction
    )

    # TODO uncomment tests for each implemented class to test its work

    # # test of the model executed with FP32 precision
    # tester = FP32Model(
    #     dataset,
    #     args.results_path / f'{args.model_path.stem}.fp32.tflite',
    #     args.model_path
    # )
    # tester.prepare_model()
    # tester.test_inference(
    #     args.results_path,
    #     'tflite-fp32',
    #     args.test_dataset_fraction
    # )

    # for calibsize in [0.01, 0.08, 0.3, 0.8]:
    #     # test of the model executed with INT8 precision
    #     tester = INT8Model(
    #         dataset,
    #         args.results_path / f'{args.model_path.stem}.int8-{calibsize}.tflite',  # noqa: E501
    #         args.model_path,
    #         calibsize
    #     )
    #     tester.prepare_model()
    #     tester.test_inference(
    #         args.results_path,
    #         f'tflite-int8-{calibsize}',
    #         args.test_dataset_fraction
    #     )

    # # test of the model executed with imbalanced INT8 precision
    # tester = ImbalancedINT8Model(
    #     dataset,
    #     args.results_path / f'{args.model_path.stem}.imbint8.tflite',
    #     args.model_path
    # )
    # tester.prepare_model()
    # tester.test_inference(
    #     args.results_path,
    #     'tflite-imbint8',
    #     args.test_dataset_fraction
    # )
