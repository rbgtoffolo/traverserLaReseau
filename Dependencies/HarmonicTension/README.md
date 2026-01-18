# Harmonic Tension

A SuperCollider class to calculate the roughness of notes or groups of notes, based on the algorithms of **Helmholtz**, **Plomp & Levelt**, **Parncutt**, and **Ferguson**.

---

## Classes

### 1. HarmonicTension
This version uses **Equal Temperament** to generate the harmonic series for each note.

#### Usage:
```supercollider
// Initialize with an array of MIDI notes
a = HarmonicTension([60, 64, 67]); 

// Set the number of harmonics for each note's series (Default: 10)
a.nHarmonics = 6; 

// Choose if overall roughness is attenuated by the amplitude of each pair (Default: false)
a.multiply = true; 

// Calculate and return the overall roughness
a.roughness;
