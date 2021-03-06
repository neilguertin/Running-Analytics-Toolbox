function [Tnew, unitsnew] = polishData(T, units)
% polishData table takes a table from processData and performs the
% following operations to make it usable:
%   Remove unnecessary or redundant columns
%   Rename columns to a consistent naming scheme
%   Validate incoming units and convert to sensible units
%   Add a calculated Pace column

arguments
    T timetable
    units cell
end

% Create new empty data structures
Tnew = timetable(T.Time);
unitsnew = {};
fields = T.Properties.VariableNames;

% Indices into new and old data structures are tracked separately
inew = 1;

for i=1:numel(fields)
    switch(fields{i})
        
        % Standard fields
        case 'altitude'
            assert(strcmp(units{i},'m'),'altitude units must be m.');
            Tnew.Altitude = T.altitude;
            unitsnew{inew} = units{i};
            inew = inew+1;
        case 'cadence'
            if ismember('Cadence',Tnew.Properties.VariableNames)
                % We've seen the Stryd 'Cadence' field already. Do nothing.
            else
                assert(strcmp(units{i},'rpm'),'cadence units must be rpm.');
                Tnew.Cadence = T.cadence .* 2;
                unitsnew{inew} = 'spm';
                inew = inew+1;
            end
        case 'distance'
            assert(strcmp(units{i},'m'),'distance units must be m.');
            Tnew.Distance = T.distance;
            unitsnew{inew} = units{i};
            inew = inew+1;
        case 'enhanced_altitude' % remove column
        case 'enhanced_speed' % remove column
        case 'fractional_cadence' % remove column
        case 'heart_rate'
            assert(strcmp(units{i},'bpm'),'heart_rate units must be bpm.');
            Tnew.HeartRate = T.heart_rate;
            unitsnew{inew} = units{i};
            inew = inew+1;
        case 'position_lat'
            assert(strcmp(units{i},'semicircles'),'position_lat units must be semicircles.');
            Tnew.Latitude = T.position_lat .* 180 ./ 2^31;
            unitsnew{inew} = 'degrees Latitude';
            inew = inew+1;
        case 'position_long'
            assert(strcmp(units{i},'semicircles'),'position_long units must be semicircles.');
            Tnew.Longitude = T.position_long .* 180 ./ 2^31;
            unitsnew{inew} = 'degrees Longitude';
            inew = inew+1;
        case 'speed'
            assert(strcmp(units{i},'m/s'),'speed units must be m/s.');
            Tnew.Speed = T.speed;
            unitsnew{inew} = 'm/s';
            inew = inew+1;
            % Build Pace column. Leave as double because smoothdata (used
            % in processing) does not accept durations.
            Tnew.Pace = 1609./60./T.speed;
            unitsnew{inew} = 'min/mile';
            inew = inew+1;
        case 'temperature' % remove column
            
        % Stryd fields
        case 'Air Power'
            assert(strcmp(units{i},'Watts'),'Air Power units must be Watts.');
            Tnew.AirPower = T.('Air Power');
            unitsnew{inew} = 'W';
            inew = inew+1;
        case 'Form Power'
            assert(strcmp(units{i},'Watts'),'Form Power units must be Watts.');
            Tnew.FormPower = T.('Form Power');
            unitsnew{inew} = 'W';
            inew = inew+1;
        case 'Power'
            assert(strcmp(units{i},'Watts'),'Power units must be Watts.');
            Tnew.Power = T.Power;
            unitsnew{inew} = 'W';
            inew = inew+1;
        case 'Ground Time'
            assert(strcmp(units{i},'Milliseconds'),'Air Power units must be Milliseconds.');
            Tnew.GroundTime = T.('Ground Time');
            unitsnew{inew} = 'ms';
            inew = inew+1;
        case 'Leg Spring Stiffness'
            assert(strcmp(units{i},'kN/m'),'Leg Spring Stiffness units must be kN/m.');
            Tnew.LegSpringStiffness = T.('Leg Spring Stiffness');
            unitsnew{inew} = 'kN/m';
            inew = inew+1;
        case 'Vertical Oscillation'
            assert(strcmp(units{i},'Centimeters'),'Vertical Oscillation units must be Centimeters.');
            Tnew.VerticalOscillation = T.('Vertical Oscillation');
            unitsnew{inew} = 'cm';
            inew = inew+1;
        case 'Cadence'
            assert(strcmp(units{i},'RPM'),'Cadence units must be RPM.');
            if ismember('Cadence',Tnew.Properties.VariableNames)
                % We've seen the standard 'cadence' field already.
                % Replace it with this one.
                Tnew.Cadence = T.Cadence .* 2;
                % Units are already set.
            else
                Tnew.Cadence = T.Cadence .* 2;
                unitsnew{inew} = 'spm';
                inew = inew+1;
            end
            
        case 'Elevation'
            % TODO
                
        % Unknown field
        otherwise
            warning(['Unknown field in T: ' fields{i}])
    end
end

end
    
    