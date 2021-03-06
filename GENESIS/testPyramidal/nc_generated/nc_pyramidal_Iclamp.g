//  ******************************************************
// 
//     File generated by: neuroConstruct v1.7.0
// 
//  ******************************************************

echo ""
echo "*****************************************************"
echo ""
echo "    neuroConstruct generated GENESIS simulation"
echo "    for project: /home/boris/git/ACnet2/neuroConstruct/ACnet2.ncx"
echo ""
echo "    Description:     "

echo "    Simulation configuration: TestPyramidals"
echo "    Simulation reference: Sim_114"
echo " "
echo  "*****************************************************"



//   Initializes random-number generator

randseed 1607406365

//   This temperature is needed if any of the channels are temp dependent (Q10 dependence) 
//   

float celsius = 6.3

str units = "GENESIS SI Units"

str genesisCore = "GENESIS2"


//   Including neuroConstruct utilities file

include nCtools 

//   Including external files

include compartments 

//   Creating element for channel prototypes

if (!{exists /library})
    create neutral /library
end

disable /library
pushe /library
make_cylind_compartment
make_cylind_symcompartment
pope

env // prints details on some global variables



//   Including channel mechanisms 
//   

include Na_pyr
make_Na_pyr

include Kdr_pyr
make_Kdr_pyr

include LeakConductance_pyr
make_LeakConductance_pyr

include Ca_pyr
make_Ca_pyr

include Kahp_pyr
make_Kahp_pyr

include Ca_conc
make_Ca_conc

//   Adding unique channel: LeakConductance_pyr__e_-66 for: LeakConductance_pyr (density: 1.420051E-9 mS um^-2, e = -66.0)

copy /library/LeakConductance_pyr /library/LeakConductance_pyr__e_-66
//   Mechanism LeakConductance_pyr has parameter e = -66.0
setfield /library/LeakConductance_pyr__e_-66 Ek -0.066 


//   Including synaptic mech 
//   



create neutral /cells

//////////////////////////////////////////////////////////////////////
//   Cell group 0: pyramidals has cells of type: pyr_4_sym
//////////////////////////////////////////////////////////////////////


create neutral /cells/pyramidals
//   Adding cells of type pyr_4_sym in region Regions_3

//   Placing these cells in a region described by: Rectangular Box from point: (0.0, 0.0, 0.0) to (200.0, 50.0, 100.0)

//   Packing has been generated by: Single cell: (400.0, -200.0, 0.0) relative to region


str compName

readcell /home/boris/git/ACnet2/neuroConstruct/simulations/Sim_114/pyr_4_sym.p /cells/pyramidals/pyramidals_0
addfield /cells/pyramidals/pyramidals_0 celltype
setfield /cells/pyramidals/pyramidals_0 celltype pyr_4_sym

//   Some of the channel mechanisms in this cell have some of their internal params changed after initialisation

str tempChanName

//   Mechanism LeakConductance_pyr has parameter e = -66.0 on group: all
//   That is the passive channel reversal potential
foreach tempChanName ({el /cells/pyramidals/pyramidals_0/#})
    //echo Resetting param Em to -0.066 on {tempChanName} 
    setfield {tempChanName} Em -0.066
end


position /cells/pyramidals/pyramidals_0 4.0E-4 -2.0E-4 0.0

str tempCompName

str tempCellName

str tempChanName

//   The concentration of: ca has an effect on rate of [Kahp_pyr]

foreach tempCompName ({el /cells/pyramidals/#/#})
    if ({exists  {tempCompName}/Ca_conc})
        if ({exists  {tempCompName}/Kahp_pyr})
            addmsg {tempCompName}/Ca_conc {tempCompName}/Kahp_pyr CONCEN Ca
        end
    end
end

//   Ion ca is transmitted by [Ca_pyr] affecting conc cell mechs: [Ca_conc]

foreach tempCompName ({el /cells/pyramidals/#/#})
    if ({exists  {tempCompName}/Ca_conc})
        if ({exists  {tempCompName}/Ca_pyr})
            addmsg {tempCompName}/Ca_pyr {tempCompName}/Ca_conc I_Ca Ik
        end
    end
end

//       Ion: ca, rev pot: 80.0 mV is present on [soma_group]

foreach tempCellName ({el /cells/pyramidals/#})
//       ca is present on [soma_group] and reversal potential of this through Ca_pyr is: 80.0 mV
//   

    foreach tempChanName ({el  {tempCellName}/soma/Ca_pyr})
        setfield {tempChanName} Ek 0.08
    end

end



//////////////////////////////////////////////////////////////////////
//   Adding 1 stimulation(s)
//////////////////////////////////////////////////////////////////////

create neutral /stim
create neutral /stim/pulse
create neutral /stim/rndspike
create pulsegen /stim/pulse/stim_Input_1_pyramidals_0

//   Adding a current pulse of amplitude: 6.0E-10 A, SingleElectricalInput: [Input: IClamp, cellGroup: pyramidals, cellNumber: 0, segmentId: 0, fractionAlong: 0.5]

//   Pulses are shifted one dt step, so that pulse will begin at delay1, as in NEURON

setfield ^ level1 6.0E-10 width1 0.5 delay1 0.099975 delay2 10000.0  
addmsg /stim/pulse/stim_Input_1_pyramidals_0 /cells/pyramidals/pyramidals_0/soma INJECT output


//////////////////////////////////////////////////////////////////////
//   Crank-Nicholson num integration method (11), using hsolve: true, chanmode: 0
//////////////////////////////////////////////////////////////////////

echo "----------- Specifying hsolve"

str cellName
foreach cellName ({el /cells/#/#})
    create hsolve {cellName}/solve
    setfield {cellName}/solve path {cellName}/#[][TYPE=compartment],{cellName}/#[][TYPE=symcompartment] comptmode 1
    setmethod {cellName}/solve 11
    setfield {cellName}/solve chanmode 0
    call {cellName}/solve SETUP
    reset
end
reset
echo "-----------Done specifying hsolve "


//////////////////////////////////////////////////////////////////////
//   Settings for running the demo
//////////////////////////////////////////////////////////////////////


float dt = 2.5E-5
float duration = 0.8
int steps =  {round {{duration}/{dt}}}

setclock 0 {dt} // Units[GENESIS_SI_time, symbol: s]

//////////////////////////////////////////////////////////////////////
//   Adding 2 plot(s)
//////////////////////////////////////////////////////////////////////

create neutral /plots


create xform /plots/GraphWin_12 [500,100,400,400]  -title "Values of Ca_conc:CONC:ca (Ca) in /cells/pyramidals/pyramidals_0: Sim_114"
xshow /plots/GraphWin_12
create xgraph /plots/GraphWin_12/graph -xmin 0 -xmax {duration} -ymin 0.0 -ymax 1.0E30
addmsg /cells/pyramidals/pyramidals_0/soma/Ca_conc /plots/GraphWin_12/graph PLOT Ca *...amidals_0/soma_Ca_conc:Ca *black

create xform /plots/pyramidals_v [500,100,400,400]  -title "Values of VOLTAGE (Vm) in /cells/pyramidals/pyramidals_0: Sim_114"
xshow /plots/pyramidals_v
create xgraph /plots/pyramidals_v/graph -xmin 0 -xmax {duration} -ymin -0.09 -ymax 0.05
addmsg /cells/pyramidals/pyramidals_0/soma /plots/pyramidals_v/graph PLOT Vm *...dals/pyramidals_0_soma:Vm *black


//////////////////////////////////////////////////////////////////////
//   Creating a simple Run Control
//////////////////////////////////////////////////////////////////////

if (!{exists /controls})
    create neutral /controls
end
create xform /controls/runControl [700, 20, 200, 140] -title "Run Controls: Sim_114"
xshow /controls/runControl

create xbutton /controls/runControl/RESET -script reset
str rerun
rerun = { strcat "step " {steps} }
create xbutton /controls/runControl/RUN -script {rerun}
create xbutton /controls/runControl/STOP -script stop

create xbutton /controls/runControl/QUIT -script quit


echo Checking and resetting...

maxwarnings 400

//////////////////////////////////////////////////////////////////////
//   Recording 2 variable(s)
//////////////////////////////////////////////////////////////////////


//   Single simulation run...

reset
str simsDir
simsDir = "/home/boris/git/ACnet2/neuroConstruct/simulations/"

str simReference
simReference = "Sim_114"

str targetDir
targetDir =  {strcat {simsDir} {simReference}}
targetDir =  {strcat {targetDir} {"/"}}

echo
echo
echo     Preparing recording of cell parameters
echo
echo

create neutral /fileout
str cellName
str compName
create neutral /fileout/cells
echo Created: /fileout/cells


//   Saving Ca_conc:CONC:ca on only one seg, id: 0, in the only cell in pyramidals

if (!{exists /fileout/cells/pyramidals})
    create neutral /fileout/cells/pyramidals
end

foreach cellName ({el /cells/pyramidals/#})
    if (!{exists /fileout{cellName}})
        create neutral /fileout{cellName}
    end

    ce {cellName}

//   Recording at segInOrigCell: soma (Id: 0), segInMappedCell: soma, section: soma, ID: 0, ROOT SEGMENT, rad: 11.5, (0.0, 0.0, 0.0) -> (0.0, 17.0, 0.0), len: 17 (FINITE VOLUME)

    compName = {strcat {cellName} /soma}
    str fileNameStr
    fileNameStr = {strcat {getpath {cellName} -tail} {".Ca_conc_CONC_ca.dat"} }
    create asc_file /fileout{compName}Ca_conc_CONC_ca
    setfield /fileout{compName}Ca_conc_CONC_ca    flush 1    leave_open 1    append 1 notime 1
    setfield /fileout{compName}Ca_conc_CONC_ca filename {strcat {targetDir} {fileNameStr}}
    
    addmsg {cellName}/soma/Ca_conc /fileout{compName}Ca_conc_CONC_ca SAVE Ca  //  .. 
    call /fileout{compName}Ca_conc_CONC_ca OUT_OPEN
    call /fileout{compName}Ca_conc_CONC_ca OUT_WRITE {getfield {cellName}/soma/Ca_conc Ca}

end

//   Saving VOLTAGE on only one seg, id: 0, in the only cell in pyramidals

if (!{exists /fileout/cells/pyramidals})
    create neutral /fileout/cells/pyramidals
end

foreach cellName ({el /cells/pyramidals/#})
    if (!{exists /fileout{cellName}})
        create neutral /fileout{cellName}
    end

    ce {cellName}

//   Recording at segInOrigCell: soma (Id: 0), segInMappedCell: soma, section: soma, ID: 0, ROOT SEGMENT, rad: 11.5, (0.0, 0.0, 0.0) -> (0.0, 17.0, 0.0), len: 17 (FINITE VOLUME)

    compName = {strcat {cellName} /soma}
    str fileNameStr
    fileNameStr = {strcat {getpath {cellName} -tail} {".dat"} }
    create asc_file /fileout{compName}VOLTAGE
    setfield /fileout{compName}VOLTAGE    flush 1    leave_open 1    append 1 notime 1
    setfield /fileout{compName}VOLTAGE filename {strcat {targetDir} {fileNameStr}}
    
    addmsg {cellName}/soma /fileout{compName}VOLTAGE SAVE Vm  //  .. 
    call /fileout{compName}VOLTAGE OUT_OPEN
    call /fileout{compName}VOLTAGE OUT_WRITE {getfield {cellName}/soma Vm}

end

//////////////////////////////////////////////////////////////////////
//   This will run a full simulation when the file is executed
//////////////////////////////////////////////////////////////////////

reset
str startTimeFile
str stopTimeFile
startTimeFile = {strcat {targetDir} {"starttime"}}
stopTimeFile = {strcat {targetDir} {"stoptime"}}
sh {strcat {"date +%s.%N > "} {startTimeFile}}

echo Starting sim: Sim_114 on {genesisCore} with dur: {duration} dt: {dt} and steps: {steps} (Crank-Nicholson num integration method (11), using hsolve: true, chanmode: 0)
date +%F__%T__%N
step {steps}

echo Finished simulation reference: Sim_114
date +%F__%T__%N
echo Data stored in directory: {targetDir}

//   This will ensure the data files don't get written to again..


str fileElement
foreach fileElement ({el /fileout/cells/##[][TYPE=asc_file]})
end
foreach fileElement ({el /fileout/cells/##[][TYPE=event_tofile]})
    echo Closing {fileElement}

    call {fileElement} CLOSE
end

//   Saving file containing time details

float i, timeAtStep
create asc_file /fileout/timefile
setfield /fileout/timefile    flush 1    leave_open 1    append 1  notime 1
setfield /fileout/timefile filename {strcat {targetDir} {"time.dat"}}
call /fileout/timefile OUT_OPEN
for (i = 0; i <= {steps}; i = i + 1)
    timeAtStep = {dt} * i
    call /fileout/timefile OUT_WRITE {timeAtStep} 
end

call /fileout/timefile FLUSH


sh {strcat {"date +%s.%N > "} {stopTimeFile}}

openfile {startTimeFile} r
openfile {stopTimeFile} r
float starttime = {readfile {startTimeFile}}  
float stoptime =  {readfile {stopTimeFile}}  
float runTime = {stoptime - starttime}  
echo Simulation took : {runTime} seconds  
closefile {startTimeFile} 
closefile {stopTimeFile} 


str hostnameFile
hostnameFile = {strcat {targetDir} {"hostname"}}
sh {strcat {"hostname > "} {hostnameFile}}
openfile {hostnameFile} r
str hostnamestr = {readfile {hostnameFile}}
closefile {hostnameFile}

str simPropsFile
simPropsFile = {strcat {targetDir} {"simulator.props"}}
openfile {simPropsFile} w
writefile {simPropsFile} "RealSimulationTime="{runTime}
writefile {simPropsFile} "Host="{hostnamestr}
closefile {simPropsFile} 
