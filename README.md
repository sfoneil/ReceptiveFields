# ReceptiveFields
MATLAB. Uses GUIDE syntax, can be updated to App Designer.
See also included PDF of an exercise.
Simulates the receptive fields (RF) corresponding to retinal ganglion cells/lateral geniculate nucleus (LGN) cells and visual cortex (V1). These RFs represent the neuronal responses to visual stimulus. This is intended to be an interactive demo and not a representation of actual cellular electrical responses.

TEST MODE
You can display the following cell types:
- Retinal/LGN center-surround cell RFs. Circular response profile, detects spots. Stimuli: Point (single pixel), Spot (3 sizes of a integrating circle), Bar (3 sizes of a bar stimulus rotating by 15 degrees.
  On-center cell. Excitatory (increased neuron firing rate) in the center, inhibitory (decreased neuron firing rate) at the edges. Stimuli: Point, Spot, Bar.
  Off-center cell. Inhibitory in the center, excitatory at the edges. Stimuli: Point, Spot, Bar.
- V1 simple cell RFs. Gabor (2D sine wave * 2D Gaussian) response of alternating excitatory and inhibitory regions. Responds strongly to orientations specific to this cell; response attenuated as it deviates from the ideal orientation. Edge or line detector. Stimuli: Point, Spot, Bar.
- Retinal/LGN color-specific center surround cell RFs. These cells respond excitatory to "preferred" wavelength in either region, inhibited in other region by another color. Cone response wavelengths are an "ideal" observer and may not correspond to an individuals' cone responses. Stimuli: no specific point but across visual field, therefore both regions stimulated simultaneously.
  +L-M. Excitatory center to L ("reddish") stimulation, inhibitory surround to M ("greenish") stimulation.
  -L+M. Inhibitory center to L stimulation, excitatory surround to M stimulation.
  +M-L. Excitatory center to M stimulation, inhibitory surround to L stimulation.
  -M+L. Inhibitory center to M stimulation, excitatory surround to L stimulation.
  +S-LM. Excitatory center to S ("bluish") stimulation, inhibitory surround to L+M ("yellowish") stimulation.
- Single photoreceptor RFs. No inhibitory regions.
  - L cone. Responds best to 570 nm.
  - M cone. Responds best to 542 nm.
  - S cone. Responds best to 448 nm.
  - Rod. Responds best to 498 nm (cyan), but does not provide a physiological color response, involved in monochrome vision, especially low light levels (scotopic).

EXPERIMENT MODE
Numbers 1 through 10 are exercises representing different RFs. See PDF for instructions and explanation.
