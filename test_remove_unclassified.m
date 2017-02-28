%% TEST: REMOVE_UNCLASSIFIED

% Create dummy data
distr_maps_segs = [0 1 2 3 4 0 0 5 -1 -1;...
                   1 0 0 2 3 4 5 0  6 -1;...
                   1 2 3 4 0 5 0 6  0 -1;...
                   0 0 3 4 5 6 7 8  9  0;...
                   1 2 0 0 0 0 5 0 -1 -1];
               
length_map = [249,222,238,244,246,234,248,245,-1,-1;...
              244,238,243,245,210,241,242,206,243,-1;...
              243,240,236,240,240,239,243,247,243,-1;...
              240,248,238,240,241,242,245,237,246,244;...
              241,248,244,242,238,242,247,238,-1,-1];
          
theshold = [500,250];          

% Solution          
solution ={[1 1 2 3  4 4  5  5 -1 -1;...
            1 1 2 2  3 4  5 -3  6 -1;...
            1 2 3 4 -3 5 -3  6  6 -1;...
            3 3 3 4  5 6  7  8  9  9;...
            1 2 0 0  0 0  5  5 -1 -1],...
            ...
           [1 1 2 3  4 0  0  5 -1 -1;...
            1 0 0 2  3 4  5 -3  6 -1;...
            1 2 3 4 -3 5 -3  6  6 -1;...
            0 0 3 4  5 6  7  8  9  9;...
            1 2 0 0  0 0  5  5 -1 -1]};  

counter = 0;
for  i = 1:length(theshold)
    output = remove_unclassified(0,distr_maps_segs,length_map,'THRESHOLD',theshold(i));
    if output == solution{i}
        fprintf(strcat('Iteration:',num2str(i),'::OK'));
        fprintf('\n');
        counter = counter + 1;
    end
end
if counter == length(theshold)
    fprintf('TEST:REMOVE_UNCLASSIFIED::Passed');
else
    fprintf('TEST:REMOVE_UNCLASSIFIED::Failed');
end
               
               
               
               