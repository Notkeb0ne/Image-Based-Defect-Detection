# <'Project Number'> <'Image-Based defect detection using Matlab'>
This is a template repository for nominated Classroom Challenge Project submissions. Note to students participating in Classroom Challenge Projects: use this template so that your project may be reviewed by the MathWorks team for a prize. Remember that only your instructor can nominate projects for MathWorks review and prize eligibility. Once you have filled out this template and uploaded your MATLAB and/or Simulink solution, notify your instructor that your project is ready for review. Your instructor will need the URL for your GitHub repository to submit your project to MathWorks for evaluation.

# Toothbrush Inspection Pipeline

MVTec AD "toothbrush" category: classical evidence (bristle segmentation +
average-image comparison) combined with a fine-tuned ResNet-18 into one
hybrid PASS/FAIL-style (good/defective) inspection system.

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

# Project Solution Instructions
Please explain step-by-step how to setup and run your project solution. Include any information about resources or external tools that might be needed to run your MATLAB code and/or Simulink model without errors.

# Results
Add a picture, plot, animation, GIF, or table to demonstrate the expected result or output of your project solution.

# Reference
Add reference papers, data, or supporting materials that have been used, if any.

# Contact (optional)
Provide the best e-mail at which to contact you and your team in the event that you are chosen to receive a prize.
