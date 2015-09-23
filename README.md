# qa - quality assurance code for 7T fMRI data

## what data?

## how to run?

- straight from ``matlab``
- in shell wrapper


## desiderata

We want to be able to run this in one of the following ways:

```matlab
  uonQA() % allow data file picking.
  uonQA('test_data_set01.nii') % NIFTI-1
  uonQA('test_data_set01.img') % NIFTI_PAIR
```

Wrapped in a shell script? If ``matlab`` is available from command line:

```bash
matlab -nodisplay -nodesktop -r "run /location/on/machine/uonQA.m"
```
( See e.g. http://uk.mathworks.com/matlabcentral/answers/29716-running-matlab-script-through-unix-bash-script )

We want the the program to output some basic info on
  - tSNR - voxel-wise temporal SNR \frac{\mu_t}{\sigma_t}
  - auto-picked ROI, given size, # of voxels?
