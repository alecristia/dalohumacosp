ACLEW DiarizationVM Tools test
==============================

This folders contains all the input/outputs of the experiments using the DiarizationVM tools on the corpus recorded in namibia.

nam
===

This folder contains the wav recordings

Golds
=====

This folder contains the gold transcriptions (in rttm) both for SAD and Diarization. 
Note that the scoring tool (dscore) raises an exception and refuses to finish the job if one RTTM is empty, so the number of RTTM varies in the gold folder for each system. Indeed, for one given file, openSat may find some speech, whereas LDC may not find speech, so for LDC this transcription has to be deleted because the scoring tool refuses empty RTTMs. Plus, some gold transcriptions are empty because there are no sounds (e.g. recorded during night, everyone is asleep).

systems
=======

This folder contains the outputs, in rttm format, for each system (LDC, open SAT without summing the speech english/speech non english posteriograms, open SAT with summing of the two aforementioned columns, and DiarTK computed using openSAT (with SUM)).

results
=======

This folder contains the dataframes outputed by dscore. 

