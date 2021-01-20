#!/usr/bin/env python
import os, sys
import numpy as np
import pandas as pd
from windtools.openfoam import InputFile

outfile = 'tslist_probes'
output_zmax = 500.0 # None
if os.path.isfile(outfile):
    sys.exit(outfile,'already exists!')

# for ideal WRF
tslist = pd.read_csv('tslist', delim_whitespace=True, comment='#',
                     names=['name','prefix','i','j'])
print('Generating',len(tslist),'sampling locations')

# SOWFA setup
setup = InputFile('../../setUp')
dx = setup['xMax'] / setup['nx']
dy = setup['yMax'] / setup['ny']
dz = setup['zMax'] / setup['nz']
if output_zmax is None:
    output_zmax = setup['zMax']
z = np.arange(dz/2, output_zmax, dz) # cell centers
print('Sampling heights:',z)

probe_template = """{name:s}
{{
    type                probes;
    functionObjectLibs ("libsampling.so");
    name                {prefix:s};
    outputControl       timeStep;
    outputInterval      1;
    fields
    (
        U
        T
        p
        p_rgh
    );
    probeLocations
    (
        """+'\n        '.join([f'({{xi:g}} {{yi:g}} {zi:g})' for zi in z])+"""
    );
}}

"""
#print(probe_template)

with open(outfile,'w') as f:
    for _,(name,prefix,i,j) in tslist.iterrows():
        xi = (i-0.5)*dx
        yi = (j-0.5)*dy
        print(name,prefix,xi,yi)
        f.write(probe_template.format(name=name,prefix=prefix,xi=xi,yi=yi))

