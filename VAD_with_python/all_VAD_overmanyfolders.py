# coding: utf-8
#!/usr/bin/python2.7

import glob
import os
import os.path
path="/home/lscpuser/B.Touati/cristia/coded"
listA=os.listdir(path)
for folders in listA:
    print(folders)
    os.chdir(path+'/'+folders)
    zizik= glob.glob('*.wav')
    for i in zizik:
        print(i)
        from VAD import big_job
        big_job(1, i)
