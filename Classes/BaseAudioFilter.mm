//
//  BaseAudioFilter.mm
//  TellYourStory
//
//  Created by Jim Young on 2/23/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#include "BaseAudioFilter.h"
#import <pthread.h>

#include "SuperpoweredMixer.h"
#include "SuperpoweredTimeStretching.h"
#include "SuperpoweredResampler.h"
#include "SuperpoweredEcho.h"
#include "SuperpoweredFlanger.h"
#include "SuperpoweredWhoosh.h"

@implementation BaseAudioFilter {

    unsigned int sampleRateHz;
    pthread_mutex_t mutex;
    unsigned int sampleCount;

    // Superpowered
    SuperpoweredAudiobufferPool *bufferPool;
    SuperpoweredMonoMixer *monoMixer;
    SuperpoweredEcho *echoFx;

    // Time Stretching
    SuperpoweredTimeStretching *lowerPitchFx;
    SuperpoweredTimeStretching *higherPitchFx;
    SuperpoweredAudiopointerList *lowerPitchOutputBuffers;
    SuperpoweredAudiopointerList *higherPitchOutputBuffers;

}

- (id)init {
    self = [super init];

    sampleRateHz = 44100;
    bufferPool = new SuperpoweredAudiobufferPool(4, 1024*1024);

    // Stretch 1
    lowerPitchFx = new SuperpoweredTimeStretching(bufferPool, sampleRateHz);
    lowerPitchFx->setRateAndPitchShift(self.pitchOne, -1);
    lowerPitchOutputBuffers = new SuperpoweredAudiopointerList(bufferPool);

    // Stretch 2
    higherPitchFx = new SuperpoweredTimeStretching(bufferPool, sampleRateHz);
    higherPitchFx->setRateAndPitchShift(self.pitchTwo, 1);
    higherPitchOutputBuffers = new SuperpoweredAudiopointerList(bufferPool);

    // Mixer
    monoMixer = new SuperpoweredMonoMixer();

    // Echo effect
    echoFx = new SuperpoweredEcho(sampleRateHz);
    echoFx->enable(NO);
    echoFx->setMix(0.2f);

    self.fade = 1.;

    return self;
}

-(void) processAudioData:(AudioBuffer)audioBuffer {

    short *stereoData = (short*)audioBuffer.mData;
    UInt32 numberOfSamples = audioBuffer.mDataByteSize / audioBuffer.mNumberChannels / sizeof(short);

    // Process audio bytes
    if(numberOfSamples > 0 && stereoData != nil) {

        // Superpowered is expecting stereo so it multiplies `numberOfSamples` by 2. We don't want this since if we only have 1 channel.
        BOOL audioBufferIsMono = (audioBuffer.mNumberChannels == 1);
        if(audioBufferIsMono)
            numberOfSamples = numberOfSamples / 2;

            // Create an input buffer for the time stretcher.
            SuperpoweredAudiobufferlistElement lowerInputBuffer;
        SuperpoweredAudiobufferlistElement higherInputBuffer;

        bufferPool->createSuperpoweredAudiobufferlistElement(&lowerInputBuffer, sampleCount, numberOfSamples + 8);
        bufferPool->createSuperpoweredAudiobufferlistElement(&higherInputBuffer, sampleCount, numberOfSamples + 8);

        // Convert the decoded PCM samples from 16-bit integer to 32-bit floating point.
        SuperpoweredStereoMixer::shortIntToFloat(stereoData, bufferPool->floatAudio(&lowerInputBuffer), numberOfSamples);
        SuperpoweredStereoMixer::shortIntToFloat(stereoData, bufferPool->floatAudio(&higherInputBuffer), numberOfSamples);
        lowerInputBuffer.endSample = numberOfSamples; // <-- Important!
        higherInputBuffer.endSample = numberOfSamples; // <-- Important!

        // Apply other effects here
        // float* lowerFloatData = bufferPool->floatAudio(&lowerInputBuffer);
        // float* higherFloatData = bufferPool->floatAudio(&higherInputBuffer);
        // echoFx->process(floatData, floatData, numberOfSamples);

        // Pitch shift
        lowerPitchFx->process(&lowerInputBuffer, lowerPitchOutputBuffers);
        higherPitchFx->process(&higherInputBuffer, higherPitchOutputBuffers);

        // Do we have some output?
        if (lowerPitchOutputBuffers->makeSlice(0, lowerPitchOutputBuffers->sampleLength)
            && higherPitchOutputBuffers->makeSlice(0, higherPitchOutputBuffers->sampleLength)) {

            while (true) { // Iterate on every output slice.
                float *lowPitchAudio = NULL;
                float *highPitchAudio = NULL;
                int samples = 0;

                // Get pointer to the output samples.
                if (!lowerPitchOutputBuffers->nextSliceItem(&lowPitchAudio, &samples)) break;
                //                if (!higherPitchOutputBuffers->nextSliceItem(&highPitchAudio, &samples)) break;

                // Mix pitch shifts together
                float *inputs[4] = { lowPitchAudio, highPitchAudio, NULL, NULL };
                float *output = lowPitchAudio;
                //                float inputLevels[4] = { _fade, 1 - _fade, NULL, NULL };
                float inputLevels[4] = { _fade, 1 - _fade, NULL, NULL };
                float outputGain = 2;

                monoMixer->process(inputs, output, inputLevels, outputGain, 2*samples);

                // Convert the time stretched PCM samples from 32-bit floating point to 16-bit integer.
                SuperpoweredStereoMixer::floatToShortInt(lowPitchAudio, stereoData, samples);
            };

            // Clear the output buffer list.
            lowerPitchOutputBuffers->clear();
            higherPitchOutputBuffers->clear();
        };

        sampleCount += numberOfSamples;
    }
}

-(void)setPitchOne:(int)pitchOne {
    if(lowerPitchFx)
        lowerPitchFx->setRateAndPitchShift(1.0, pitchOne);
        }

-(void)setPitchTwo:(int)pitchTwo {
    if(higherPitchFx)
        higherPitchFx->setRateAndPitchShift(1.0, pitchTwo);
        }

-(void) dealloc {
    delete monoMixer;
    delete lowerPitchFx;
    delete higherPitchFx;
    delete bufferPool;
    delete lowerPitchOutputBuffers;
    delete higherPitchOutputBuffers;
}

@end

