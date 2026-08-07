# Image-Based Toothbrush Defect Detection with MATLAB
This project highlights the growing demand for automated inspection systems and the benefits machine learning can provide in improving their efficiency and reliability. Furthermore, a hybrid approach combining traditional image processing with machine learning allows system performance to be measured, monitored, and continuously improved.

# Toothbrush Inspection Pipeline

Through MATLAB’s machine learning and image classification capabilities, this project demonstrates the use of image processing, data partitioning, and classification algorithms to create a reliable system for inspecting potentially defective units.

Using the MVTec AD “toothbrush” dataset, the project implements two approaches to defect detection. First, bristle segmentation and image comparison are used to create a rule-based inspection method, where binary masks, image averages, and extracted visual differences are used to determine whether a toothbrush passes or fails inspection.

Additionally, a ResNet-18 convolutional neural network (CNN) is trained using MATLAB’s deep learning tools to classify toothbrush images. By combining the traditional image-processing approach with machine-learning classification, the project demonstrates a hybrid PASS/FAIL inspection system for automated manufacturing quality control.

Please add the following items:
* Short project description, including the MathWorks project number (on the GitHub page for the project)

# Project Details (Briefly describe your team's approach to the project and how you implemented your solution.)


                 Input Toothbrush Image
                           │
              ┌────────────┴────────────┐
              │                         │
       Classical Vision             ResNet-18
              │                         │
      Bristle Segmentation         CNN Classification
              │                         │
     Average-Image Difference            │
              │                         │
      Evidence Metrics                  │
              │                         │
       Rule Decision                    │
              │                         │
              └────────────┬────────────┘
                           │
                    Hybrid Inspection
                           │
                     GOOD / DEFECTIVE
Inspection Pipeline
Input & Data Categorization: Input images are organized and labeled using predefined markers to establish known good and defective samples.

Classical Computer Vision: MATLAB image-processing features such as grayscale conversion, thresholding, and binary masking are used to extract pixel-level information from each image.

Bristle Segmentation: Visual characteristics are used to isolate the toothbrush bristle region, producing a binary/grayscale representation that can be analyzed mathematically.

Average-Image Difference: Images are compared against an averaged reference image. Matrix operations quantify differences between the reference and inspected toothbrushes to help distinguish normal and defective samples.

Evidence Metrics: Measurements from the image comparison are quantified to determine the strength of evidence for a PASS or FAIL decision.

Rule-Based & Neural Network Classification: The classical vision system produces a rule-based decision while a ResNet-18 CNN independently classifies the image, creating two methods of evaluating the same part.

Hybrid Decision: Results from the rule-based and CNN classifiers are compared. Agreement between the two provides additional confidence in the final PASS/FAIL inspection result, while disagreement can be flagged for further review.

Evaluation & Improvement: Inspection results are recorded and evaluated using metrics such as accuracy, false accepts, false rejects, and classifier disagreement, allowing the system's performance to be monitored and improved.

## Requirements

The project was developed using **MATLAB Online**.

**Required MathWorks products:**
* MATLAB
* Deep Learning Toolbox
* Image Processing Toolbox
* Deep Learning Toolbox Model for ResNet-18 Network support package

> **Note:** The ResNet-18 support package may be downloaded automatically when the pretrained network is loaded for the first time.

---

## Dataset Setup

1. The `toothbrush/` dataset is not included in the repository and must be downloaded separately from the official MVTec dataset page.
2. After downloading the dataset, extract the `toothbrush` category so that the project can access the training and test images.
3. The project creates its own labeled dataset files:
   * `toothbrushLabels.csv`
   * `toothbrushLabels_train.csv`
   * `toothbrushLabels_test.csv`

The dataset is organized into `good` and `defective` labels for the supervised classification workflow.

---

## How to Run the Project

### Recommended: Run the MATLAB Scripts

1. Start MATLAB and open the project directory.
2. Make sure the `toothbrush` dataset is available.
3. Run the dataset organization script:

  * `organizeToothbrushDataset`

Train the classifier:
  * `trainToothbrushClassifier`

Run the complete inspection evaluation:
  * `runInspectionSuite`

Run the robustness evaluation:
  * `testRobustness`
The project uses separate helper functions for the individual inspection tasks. The main single-image inspection function is inspectPart.m. The project does not rely on a persistent MATLAB Online Current Folder between sessions. File paths are anchored to the project/script locations where necessary so that the project can continue to locate its resources after a new MATLAB Online session.

## Training Configuration

The final project uses the following primary configuration:

| Setting | Value |
| :--- | :--- |
| **Dataset** | MVTec AD toothbrush |
| **Classes** | good / defective |
| **Network** | ResNet-18 |
| **Training Method** | Transfer learning |
| **Test Set** | 31 images |
| **Good Test Images** | 22 |
| **Defective Test Images** | 9 |
| **Saved Model** | `toothbrushClassifier.mat` |
| **Input Inspection Function** | `inspectPart.m` |
| **Evaluation Script** | `runInspectionSuite.m` |
| **Robustness Script** | `testRobustness.m` |

> **Note:** Additional model configurations were investigated during development, including ResNet-18 with early layers frozen and SqueezeNet.

---

## Reproducing the Results

1. Use the software and dataset setup listed above.
2. Start from a clean MATLAB workspace.
3. Run `organizeToothbrushDataset.m` to create the labeled dataset and fixed split.
4. Run `trainToothbrushClassifier.m` to train and save the AI classifier.
5. Run `runInspectionSuite.m` to evaluate the inspection system on the held-out test set.
6. Run `testRobustness.m` to evaluate the system under simulated image variations.
7. Review the generated CSV files, figures, and inspection outputs.

The trained classifier is saved as `toothbrushClassifier.mat`, allowing the evaluation scripts to use the trained model without retraining it.

# Results
Add a picture, plot, animation, GIF, or table to demonstrate the expected result or output of your project solution.
<img width="903" height="558" alt="Screenshot_2026-08-07_at_4 45 04_PM" src="https://github.com/user-attachments/assets/81c2e6f9-65f8-4d32-8b3a-44ad53ed8cc0" />
<img width="903" height="558" alt="Screenshot_2026-08-07_at_4 44 50_PM" src="https://github.com/user-attachments/assets/8e43691d-9d98-48ec-a69b-d9007611a442" />
<img width="903" height="558" alt="Screenshot_2026-08-07_at_4 44 35_PM" src="https://github.com/user-attachments/assets/1204422d-40fc-4f3f-91de-99ac4071fe67" />



# Reference
Highly Recommended

    MATLAB Onramp
    Image Processing Onramp
    Machine Learning Onramp
    Deep Learning Onramp

## Generated Outputs

The project produces the following main files:

| File | Description |
| :--- | :--- |
| `toothbrushLabels.csv` | Complete labeled toothbrush dataset |
| `toothbrushLabels_train.csv` | Fixed training split |
| `toothbrushLabels_test.csv` | Fixed held-out test split |
| `toothbrushClassifier.mat` | Saved trained classifier |
| `toothbrushInspectionOutcomes.csv` | Saved inspection results |
| `inspectPart.m` | Hybrid single-image inspection |
| `runInspectionSuite.m` | Task 4 evaluation |
| `testRobustness.m` | Task 5 robustness evaluation |

---

## Dataset Attribution and License

The toothbrush images are from **MVTec AD**:

> Paul Bergmann, Michael Fauser, David Sattlegger, and Carsten Steger, *"MVTec AD — A Comprehensive Real-World Dataset for Unsupervised Anomaly Detection,"* IEEE/CVF Conference on Computer Vision and Pattern Recognition, 2019.

The dataset is **Copyright © 2019 MVTec Software GmbH**. Refer to the official MVTec dataset documentation for current dataset license and usage conditions.
