function [lib, resStream, inlet] = OpenBCIConnect

    %Establishes a connection with the OpenBCIGui. Make sure the OpenBCI
    %interface has 'Networking' set to LSL and the Stream 1 set to
    %'Time Series'. Start the LSL Stream
    
    disp('Loading the LSL Library');
    lib = lsl_loadlib();
    disp('Library Loaded');

    % Set-up Connection and Resolve an EEG Stream
    disp('Resolving an EEG stream');
    resStream = {};
    resolvec = 1;
    while isempty(resStream)
        resStream = lsl_resolve_byprop(lib,'type','EEG'); 
        if isempty(resStream)
            disp(resolvec)
        else
            disp('Connected Successfully')
        end
        resolvec = resolvec + 1;
        if resolvec == 6 %Wait for 5 iterations before shutting down
            disp('Could not resolve. Please check if Stream has started and try again.')
            inlet = -1;
            return
        end
    end

    %Connecting to an Inlet
    inlet = lsl_inlet(resStream{1});
end