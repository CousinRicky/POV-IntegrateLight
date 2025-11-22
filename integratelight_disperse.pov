/* integratelight_disperse.pov version 1.0.3-rc.2
 * Persistence of Vision Raytracer scene description file
 * POV-Ray Object Collection demo
 *
 * Demo of selected lamps prepared with IntegrateLight, viewed through a prism.
 *
 * Copyright (C) 2016 - 2025 Richard Callwood III.  Some rights reserved.
 * This file is licensed under the terms of the GNU-LGPL.
 *
 * This library is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please
 * visit https://www.gnu.org/licenses/lgpl-3.0.html for the text
 * of the GNU Lesser General Public License version 3.
 *
 * Vers.  Date         Comments
 * -----  ----         --------
 *        2016-Jul-09  Started.
 * 1.0    2016-Nov-14  Uploaded.
 * 1.0.1  2019-Mar-31  The normalization is changed from .gray to xyY.
 * 1.0.2  2023-Mar-14  Callwood's modifications to SpectralComposer.pov are used
 *                     if available.
 *        2024-Dec-29  The #version is preserved between 3.7 and 3.8.
 *        2025-Oct-12  The license is upgraded to LGPL 3.
 * 1.0.3  2025-Nov-21  Luminance-based gamut mapping is recognized, and a bit of
 *                     gray is added to the background to bring out the violets.
 */
// Pass 1:
//   +W640 +H480 +A +AM2 +R3 -J +FE +KI1 +KF36 +KFI38 +KFF73
// Pass 2:
//   +W640 +H480 -A
// Before running pass 2, make sure ALL of the #declare FName lines in
// SpectralComposer.pov are commented out.
//
// After running pass 2, you may delete the integratelight_disperse??.exr files.
#version max (3.7, min (3.8, version)); // Bracket the POV version.

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREATE THE SCENE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#if (clock_on)

  #ifndef (Annot) #declare Annot = no; #end
  #ifndef (Debug) #declare Debug = no; #end
  #ifndef (Lamp) #declare Lamp = 9; #end

  #include "screen.inc"
  #include "spectral.inc" // from SpectralRender
  #include "integratelight.inc"
  #include "espd_cie_standard.inc" // from Lightsys IV

  global_settings { assumed_gamma 1 }

  Set_Camera (<-1, 0, -100>, <0.9, 0, 0>, 1.8)

  background { SpectralEmission (E_D65) * (Debug? 0.2: 0.02) }

  //================================= PRISM ====================================

  prism
  { -1, 1, 4, <2, 0>, <-1, -sqrt(3)>, <-1, sqrt(3)>, <2, 0>
    scale 1.2
    #if (Debug)
      // for debugging, a material that stands out from the
      // background, but still transmits across the spectrum:
      M_Spectral_Filter (D_Amethyst, IOR_Glass_BK7, 1)
    #else
      M_Spectral_Filter (Value_1, IOR_Glass_BK7, 100)
    #end
  }

  //================================= LIGHT ====================================

  #macro Set_light (Curve)
    #declare Emitter = ILight_Continuous (Curve, no, ILIGHT_XYY, 1);
  #end

  // Identifiers starting with ES_ are from Lightsys IV include files.
  #switch (floor (Lamp))
    #case (0) Set_light (ILight_Blackbody (2856)) #break // Illuminant A
    #case (1) Set_light (ILight_Daylight (5003)) #break  // Illuminant D50
    #case (2) Set_light (ILight_Daylight (6504)) #break  // Illuminant D65
    #case (3) Set_light (ES_Illuminant_F2) #break  // standard fluorescent
    #case (4) Set_light (ES_Illuminant_F9) #break  // broadband fluorescent
    #case (5) Set_light (ES_Illuminant_F11) #break // narrowband fluorescent
    #case (6) Set_light (ES_GE_SW_Incandescent_60w) #break
    #case (7) Set_light (ES_Nikon_SB16_XenonFlash) #break
    #case (8)
      #declare CIE_IntegralStep = 1;
      Set_light (ES_Phillips_HPS)
      #break
    #case (9)
      #declare CIE_IntegralStep = 1;
      Set_light (ES_Phillips_PLS_11w)
      #break
    #case (10) Set_light (ES_Solux_Halog4700K) #break
    #case (11) Set_light (ES_Sunlight) #break
    #else Set_light (spline { linear_spline 380, 0, 730, 0 }) #break
  #end

  cylinder
  { -y, y, 0.2
    scale <1, 1.4, 1>
    pigment { aoi color_map { [0.5 rgb 0] [1.0 SpectralEmission (Emitter)] } }
    finish { ambient 0 diffuse 0 emission 1 }
    translate <-21.5, 0, 20>
  }

  //============================== ANNOTATIONS =================================

  #if (Annot)

    #declare NLAMPS = 12;
    #declare s_Lamps = array[NLAMPS]
    { "Illuminant A",
      "Illuminant D50",
      "Illuminant D65",
      "Illuminant F2",
      "Illuminant F9",
      "Illuminant F11",
      "GE soft white incandescent 60 W",
      "Nikon SB-16 xenon flash",
      "Philips high pressure sodium",
      "Philips PL-S 11 W CFL",
      "SoLux 4700K halogen",
      "Sunlight",
    }

    Screen_Object
    ( text
      { ttf "cyrvetic"
        #if (Lamp >= 0 & Lamp < NLAMPS)
          s_Lamps[Lamp]
        #else
          concat (str (Lamp, 0, -1), "???")
        #end
        0.001, 0
        T_Spectral_Emitting (E_D65, 0.8)
        scale 0.07
      },
      <0.5, 0.5>, 0, yes, 1
    )

  #end

//%%%%%%%%%%%%%%%%%%%%%%%%%%% ASSEMBLE THE FRAMES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#else

  #declare FName = "integratelight_disperse"
  #if (file_exists ("SpectralComposer.inc"))
    // from https://github.com/CousinRicky/POV-SpectralRender-mods
    // version RC3-0.22-3 or later; otherwise, use SpectralComposer-gm2.inc
    #declare GamutMap = 4; // luminance-based
    #include "SpectralComposer.inc"
  #else
    // from SpectralRender
    // IMPORTANT:
    // Make sure ALL of the #declare FName lines in SpectralComposer.pov
    // are commented out, or the above #declare FName will be overridden!
    #include "SpectralComposer.pov"
  #end

#end

// End of integratelight_disperse.pov
