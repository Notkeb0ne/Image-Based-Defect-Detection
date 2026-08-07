# <'Project Number'> <'Image-Based defect detection using Matlab'>
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

# Project Solution Instructions
Please explain step-by-step how to setup and run your project solution. Include any information about resources or external tools that might be needed to run your MATLAB code and/or Simulink model without errors.

# Results
Add a picture, plot, animation, GIF, or table to demonstrate the expected result or output of your project solution.

# Reference
Add reference papers, data, or supporting materials that have been used, if any.

# Contact (optional)
Provide the best e-mail at which to contact you and your team in the event that you are chosen to receive a prize.
