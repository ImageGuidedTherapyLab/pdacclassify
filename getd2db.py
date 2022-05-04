import os
import csv
csvdata = csv.DictReader(open("dicom/wideformatd2.csv"))
data = {}
for row in csvdata:
    if(row['PatientID'] in data.keys()):
        print("{name} already recorded!".format(name = row['PatientID']))
        raise ValueError
    data[row['PatientID']] = row


# setup command line parser to control execution
from optparse import OptionParser
parser = OptionParser()
parser.add_option( "--uid",
                  action="store", dest="uid", default=None,
                  help="pt uid", metavar="FILE")
parser.add_option( "--bl",
                  action="store_true", dest="bl", default=None,
                  help="series directory", metavar="FILE")
parser.add_option( "--nrm",
                  action="store_true", dest="nrm", default=None,
                  help="series directory", metavar="FILE")
parser.add_option( "--art",
                  action="store_true", dest="art", default=None,
                  help="series directory", metavar="FILE")
parser.add_option( "--keys",
                  action="store_true", dest="keys", default=None,
                  help="pt list", metavar="FILE")
(options, args) = parser.parse_args()

if(options.keys ):
  print(' '.join(  data.keys()))
elif(options.art and options.uid != None ):
  print(data[options.uid]['ArtFilename'])
elif(options.nrm and options.uid != None ):
  print(data[options.uid]['Truth1FileName'])
elif(options.bl and options.uid != None ):
  print(data[options.uid]['Truth2FileName'])
#elif(options.tc and options.uid != None ):
#  print(data[options.uid]['TCseriesdir'])
#elif(options.accession and options.uid != None ):
#  print(data[options.uid]['accession'])
#elif(options.uid and (options.minresolution or options.maxresolution or options.T2resolution) ):
#  import nibabel as nib
#  import numpy as np
#  flimg = nib.load("Processed/%s/fl.nii.gz" % options.uid)
#  t2img = nib.load("Processed/%s/t2.nii.gz" % options.uid)
#  t1img = nib.load("Processed/%s/t1.nii.gz" % options.uid)
#  tcimg = nib.load("Processed/%s/tc.nii.gz" % options.uid)
#  imglist = ['FL','T2','T1','TC'];
#  voxelarray = [
#   flimg.shape[0] * flimg.shape[1] * flimg.shape[2],
#   t2img.shape[0] * t2img.shape[1] * t2img.shape[2],
#   t1img.shape[0] * t1img.shape[1] * t1img.shape[2],
#   tcimg.shape[0] * tcimg.shape[1] * tcimg.shape[2]  ]
#  if(options.minresolution ):
#    myind = np.argmin(voxelarray )
#    seriesdir = data[options.uid]['%sseriesdir' % imglist[myind] ]
#  if(options.maxresolution ):
#    myind = np.argmax(voxelarray )
#    seriesdir = data[options.uid]['%sseriesdir' % imglist[myind] ]
#  if(options.T2resolution ):
#    seriesdir = data[options.uid]['T2seriesdir'                  ]
#  imagelist = os.listdir(seriesdir )
#  print('%s/%s' % (seriesdir,imagelist[0]) )
else:
  parser.print_help()
  print (options)
