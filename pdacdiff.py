import subprocess
import os
import numpy as np
import nibabel as nib  

# raw dicom data is usually short int (2bytes) datatype
# labels are usually uchar (1byte)
IMG_DTYPE = np.int16
SEG_DTYPE = np.uint8
_globalexpectedpixel=512

# setup command line parser to control execution
from optparse import OptionParser
parser = OptionParser()
parser.add_option( "--image",
                  action="store", dest="image", default=None,
                  help="anatomy image", metavar="FILE")
parser.add_option( "--mask",
                  action="store", dest="mask", default=None,
                  help="mask image", metavar="FILE")
parser.add_option( "--output",
                  action="store", dest="output", default='.',
                  help="output path image", metavar="FILE")
(options, args) = parser.parse_args()


if (options.image != None and options.mask != None ):
    imagedata = nib.load(options.image)
    numpyimage= imagedata.get_data().astype(IMG_DTYPE )
    print(numpyimage.shape)
    # error check
    assert numpyimage.shape[0:2] == (_globalexpectedpixel,_globalexpectedpixel)

    getHeaderCmd = 'c3d %s %s -lstat | sed "s/^\s\+//g;s/\s\+/,/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" ' % (options.image,options.mask)
    print(getHeaderCmd )
    try: 
      headerProcess = subprocess.Popen(getHeaderCmd ,shell=True,stdout=subprocess.PIPE ,stderr=subprocess.PIPE)
      while ( headerProcess.poll() == None ):
         pass
      rawoutput  =   headerProcess.stdout.readline()
      headerinfo =  rawoutput.decode('utf-8').strip('\n')
      rawlstatinfo = [ dict(zip(headerinfo.split(','),map(float,line.decode('utf-8').strip('\n').split(','))))  for line in headerProcess.stdout.readlines()]
      labeldictionary = dict([ (int(datdic['LabelID']),{'Mean':datdic['Mean'],'StdD':datdic['StdD'],'Vol.mm.3':datdic['Vol.mm.3']}) for datdic in rawlstatinfo if int(datdic['LabelID']) > 0 ] )
    except (NameError, SyntaxError) as excp: 
      print(excp)
    xoffset = -labeldictionary[1]['Mean']
    shiftcmd = 'c3d %s -shift %12.5e  -type float -o %s ' % (options.image,xoffset , options.output )
    print(shiftcmd )
    os.system(shiftcmd )
    verifyrescalecmd = 'c3d %s %s -lstat  ' % (options.output, options.mask)
    print(verifyrescalecmd )
    os.system( verifyrescalecmd  )
else:
  parser.print_help()
  print(options)
 
