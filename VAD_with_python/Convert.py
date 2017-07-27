# coding: utf-8

def read_file(Input):
    x=open(Input, 'r')
    Doc_lines=x.readlines()
    x.close()
    return(Doc_lines)

#Concatenante V
def concaten(V):
    V2=''.join(V)
    #print(V2)
    return(V2)

#Collect the string corresponding to tmin or tmax
def past_append(MinorMax, Limite, j):
    y=0
    past=[]
    if j==1:
        while MinorMax[y]!=',':
            y+=1
        y+=1
    while (MinorMax[y]!=Limite):
        past.append(MinorMax[y])
        y+=1
        #print(y)
    return(past)

def define_time(Doc_lines, string, tmax):
    i=0
    time=[]
    while i <(len(Doc_lines)-2):
        TimeA=past_append(Doc_lines[i],string,tmax)
        TimeB=concaten(TimeA)
        time.append(TimeB)
        i+=1
    return(time)

def a_ecrire(Tmax, Tmin):
    Tmax=float(Tmax)
    Tmin=float(Tmin)
    if Tmax>180 and Tmin<240:
        if Tmin<180:
            Tmin=180
        if Tmax>240:
            Tmax=240
        Insert=(str(Tmin),'Speech','1',str(Tmax))
    else:
        Insert="NA"
    return(Insert)

def create_speech(tmax, tmin):
    Insert=[]
    speech=[]
    i=0
    while i<len(tmax):
        Insert= a_ecrire(tmax[i],tmin[i])
        if Insert!="NA":
           print(Insert)
           speech.append(Insert)
        i+=1
    return(speech)

def write_in_file(speech, Output):
    i=0
    chn='tmin, tier, text, tmax'
    for i in range(len(speech)):
        chn+="\n"+", ".join(speech[i])
        i+=1
    f= open(Output, 'w')
    f.write(chn)
    f.close()

def create_file(Input, Output):
    Doc_lines=read_file(Input)
    tmin=define_time(Doc_lines,',',0)
    tmax=define_time(Doc_lines,'\n',1)
    speech=create_speech(tmax, tmin)
    write_in_file(speech, Output)

def main():
    Input='Baqu-20171112_txt_01_1800_2100_XVAD.csv'
    Output='Baqu-20171112_txt_VAD0.03.csv'
    create_file(Input, Output)

if __name__ == '__main__':
    main(sys.argv[1:])
