#Extended Build Replacement

The steps below describe how to port build processes in OpenShift that use the now-unavailable "Extended Builds" feature to a functionally equivalent configuration.

#What are Extended Builds?

Extended Builds were a feature available in OpenShift up to and including version 3.6.

Extended Builds were a mechanism to "overlay" the output from one build into an existing image, where the build of the initial image *and* instruction for the "overlay" were defined in a single Build Configuration.

The most common use case is where an application's build-time requirements are different than its runtime requirements.    

Extended Builds are no longer supported, but there are alternative ways to achieve the same functionality via "Chained Builds".  This document describes the process of migrating from using Extended Builds to Chained Builds.   

##Create a new Build Configuration

First, we need to create a *new* Build Configuration that will perform the work previously done as one of the stages of the Extended Build.

In the most common 
