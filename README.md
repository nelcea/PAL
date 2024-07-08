PAL is the generic project for my research in the world of Wearable AI.
For some more background on the project, see [The PAL Project - Bokeh](https://www.ericbariaux.com/posts/the-pal-project/)

In a first phase, I catalogued the main projects currently underway at [Pinboard - Wearable AI projects](https://www.ericbariaux.com/pinboard/).

I intend to test as many of them as possible, learning what works or not and distill the ideas that most align with what I'm trying to achieve in this project.

I also intend to develop a solution of my own, which is what this repository contains.

The first part of the code is now available.  
It is an iOS application that uses [Friend](https://github.com/BasedHardware/Friend) hardware to record conversations.  
At this stage, it only the audio transmitted over BLE and stores it on the phone.
There is some basic possibility to organise the recordings and share them.
There's also a first test on using the on-device speech recognition for transcription but it's work in progress.
There was no effort on the UI/UX at this stage and code needs a bit of clean-up.  
It's provided as is for people that would already find it useful or want to see how to setup a connection with Friend.  

Known issues:
- Opus codec not implemented
- Battery drain