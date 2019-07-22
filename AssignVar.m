function [] = AssignVar(VarA, VarB)
    assignin('caller', VarA, VarB)
end
