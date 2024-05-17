PAL is the generic project for my research in the world of Wearable AI.

In a first phase, I catalogued the main projects currently underway at [Pinboard - Wearable AI projects](https://www.ericbariaux.com/pinboard/).

I intend to test as many of them as possible, learning what works or not and distill the ideas that most align with what I'm trying to achieve in this project.

In a first instance, I approach this as part of my PKM / BASB exploration.

Some key aspects I'd like to take into account:
- privacy, running as much as possible locally
- disconnected, should be able to use as many features as possible without an internet connection

The first part of the code is now available.  
It is an iOS application that uses [Friend](https://github.com/BasedHardware/Friend) hardware to record conversations.  
At this stage, it only records the audio transmitted over BLE and stores it on the phone.  
There is no processing, transcription, summarization or chat ability at this stage.  
There was no effort on the UI/UX at this stage and code needs a bit of clean-up.  
It's provided as is for people that would already find it useful or want to see how to setup a connection with Friend.  
