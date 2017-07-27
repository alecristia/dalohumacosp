# coding: utf-8

import glob

zizik= glob.glob('*.wav')
for i in zizik:
    print(i)
    from decoupe import big_job
    big_job(1, i)
