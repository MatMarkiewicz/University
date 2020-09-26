# Cancel cancer (Neural Nets and Deep Learning project)
## Prostate cancer diagnosis using the ISUP grading system.
Artur Derechowski, Mateusz Markiewicz, Krzysztof Nyczka

## Problem description
With more than 1 million new diagnoses reported every year, prostate cancer (PCa) is the second most common cancer among males worldwide that results in more than 350,000 deaths annually. The key to decreasing mortality is developing more precise diagnostics. Diagnosis of PCa is based on the grading of prostate tissue biopsies.

These tissue samples are examined by a pathologist and scored according to the Gleason grading system. In this project, we will develop model for detecting PCa on images of prostate tissue samples, and estimate the severity of the disease using the most extensive multi-center dataset on Gleason grading available yet.

## Data description and visualization
The training set consists of around 11,000 whole-slide images of digitized biopsies originating from two medical centers. This is the largest publicly available whole-slide image dataset, roughly 8 times the size of the CAMELYON17 challenge, one of the largest digital pathology datasets and best known challenges in the field. Furthermore, there are full diagnostic biopsy images available. Using a sizeable multi-center test set, graded by expert uro-pathologists, challenge submissions will be evaluated based on their applicability to improve this critical diagnostic function.

Every image has two labels, because it has been graded in two scales: Gleason scale and ISUP scale. The grading system named after the american doctor consists of two numbers, which stand for two most commonly occuring cancer cell types. Submissions are however graded by the ISUP grading system. There is straightforward mapping from Gleason to ISUP, so there is a possiblity to train a model to classify images that way.

![](https://i.imgur.com/q9Ujes4.png)

![](https://i.imgur.com/kIGmO2q.png)

## Our approach

There are images with masks pointing out which part of the image should be searched for cancer cells (important for Gleason scoring) and also those without masks. There is a small difference in those sets sizes - some images lack masks. This indicates that the Gleason approach would have slightly fewer training samples (by around 100).

We choose to make the classfication based on the ISUP ranking, since it's less time-consuming to train a network that way. Another thing is that we tried to project this 6-class classification problem into regression with one number corresponding to a (0,5) scale. We've shown experimentaly that classification works slightly better in this case.

![](https://i.imgur.com/EkTTZi2.png)

Then, since prostate biopsies are mostly empty images, we decide to cut them into squares that include only valuable information and then merge them in some potentially promising order. We tried to preprocess them before training, to minimize the number of the exactly same computations. Also we decided to compress the images into `.png`, because it's not such a heavy format compared with `.tiff`. Since it didn't speed up the process significantly, it was easier for us to work with the original data format.

![](https://i.imgur.com/g0uMj9b.png)

After normalizing the preprocessed images, we put them in a dataset, that we divide into 4 folds to process cross-validation. Our model is SE-ResNext50 network which was originally pretrained on ImageNet. We proceed with training to adjust weights, having around 0.8 kappa score during that process.

![](https://miro.medium.com/max/2000/1*x3qCQ7Ep_eKSJC6TSmhebA.png)

#### Testing
Firstly, it was 64 per batch of `.png` images (64x64) using regression model with ADAM optimizer(learing rate = 1e-4) and Alphas scheduler factor = 0.5. After three epochs we got QWK on cross-validation ~ 0.79. **Leaderboard QWK: 0.55**. After fixing some bug with the shape we made a large leap into **LB QWK: 0.72**

Secondly, since `.png` usage didn't speed up computation, we decided to go back to `.tiff`, cut and padded on-line. This time we did images in classification model with the same parameters. Different fold concatenation resulted in Validation QWK~0.75. **Leaderboard QWK: 0.74**

After that we tested our solution with different parameteres such as:
- batch and image size. 16 x 128 x 128, 64 x 64 x 64, 256 x 32 x 32. Option 64x64x64 works slightly better than the others.
- image padding and concatenation. We tried to merge little squares randomly, by the amount of valuable pixels and using heuristic that tried to put image pieces as closly to their original location as posibble. Third option performed the best.
- SGD parametrization (but since ADAM performed much better, we abandoned the SGD)
- Alpha scheduler's factor. Usually 0.25 gave best results.
- transformation parameters. Classical horizontal and vertical flips with random probability and previously calculated normalization inputs worked the best.

Later on we did regression on `.tiff` 64x64x64, ADAM(learning rate=1e-4) with Alpha factor=0.25 on 25 epochs. QWK on cross-validation ~ 0.83. **Leaderboard QWK: 0.78** (position 380 from about 650 participants at the moment of submission)

Several small chages led to QWK on cross-validation ~ 0.87 and **LB QWK: 0.77**. So our best submission was the one pointed out 4 lines above.

## Plans

If we were to continue work the first thing to improve is choosing more appropriate parameters (including number of epochs). We choose those ones that maximalize QWK on Cross-Validation, but despite that valid parts aren't overlapping the difference between CV and LB scores is huge. Maybe testing data has a slightly different distribution than the training set (class distribution is different for both data providers). 

## What we learned

We learned how to make a project from scratch to final results -  we had to deal with large data and we get to know how to reduce them keeping maximum information. We learned a lot about re-training a bigger net that those we used on assignments and how to choose parameters when full-training took about 20 hours (keeping in mind that our computing time was limited). Finally, we experienced that making an appropriate model is a really hard task, we spent long hours trying to find the best parameters, but our leaderboard position remains unsatisfactory.
