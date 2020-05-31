function processMetadata(fit, metadata)
% processMetadata takes a struct containing metadata directly from the fit
% file, extracts the useful information, and puts it in the given FitFile
% object.
% Most enums are interpreted using the information from fit_profile.hpp

arguments
    fit FitFile
    metadata struct
end

% Used in validation later
seen_file_id_message = false;
seen_session_message = false;

for i=1:numel(metadata)
    m = metadata(i);
    
    switch(m.name)
        
        case 'file_id'
            % Contains file-level information. Guaranteed to be in every
            % .fit file
            seen_file_id_message = true;
            for j=1:numel(m.fields)
                switch(m.fields{j})
                    case 'time_created'
                        fit.StartTime = timestamp2datetime(m.values{j});
                    case 'type'
                        assert(m.values{j} == 4,'File must be an activity file')
                    case {'serial_number', 'product_name', 'manufacturer', 'product', 'number'}
                        % do nothing
                    otherwise
                        warning(['Unknown field in ' m.name ' message: ' m.fields{j}])
                end
            end
            
        case 'activity'
            % Guaranteed to be in every activity .fit file. Since only one
            % session per activity is supported, most of this information
            % will come from the session message instead.
            for j=1:numel(m.fields)
                switch(m.fields{j})
                    case 'num_sessions'
                        assert(m.values{j} == 1,'File must have exactly one session');
                    case 'timestamp'
                    case 'local_timestamp'
                    case 'total_timer_time'
                    case 'type'
                    case 'event'
                    case 'event_type'
                    otherwise
                        warning(['Unknown field in ' m.name ' message: ' m.fields{j}])
                end
            end
            
        case 'event'
            % Unsure if there is any useful information in any event messages.
%             for j=1:numel(m.fields)
%                 switch(m.fields{j})
%                     case 'timestamp'
%                     case 'event'
%                         switch(m.values{j})
%                             case 0 % Timer event
%                             case {38, 39, 48} % Appear in garmin data, not in fit_profile.hpp
%                             case 21 % FIT_EVENT_RECOVERY_HR, appears when paused
%                             case 9 % FIT_EVENT_LAP, appears on Timex laps
%                             otherwise
%                                 warning(['Unknown event: ' num2str(m.values{j})])
%                         end
%                     case 'event_type'
%                     case 'event_group'
%                     case 'data'
%                     otherwise
%                         warning(['Unknown field in ' m.name ' message: ' m.fields{j}])
%                 end
%             end
            
        case 'lap'
            lap = Lap;
            for j=1:numel(m.fields)
                switch(m.fields{j})
                    case 'timestamp'
                        lap.StopTime = timestamp2datetime(m.values{j});
                    case 'start_time'
                        lap.StartTime = timestamp2datetime(m.values{j});
                    case 'total_elapsed_time'
                        % Elapsed time gives split on the Timex
                        % Calculate using timestamps instead
                        % lap.ElapsedTime = duration(0,0,m.values{j});
                    case 'total_timer_time'
                        lap.TimerTime = duration(0,0,m.values{j});
                    case {'message_index','repetition_num'}
                        lap.LapNumber = m.values{j} + 1;
                    case 'event'
                        assert(m.values{j} == 9,'Message must be a lap')
                    case 'event_type'
                        assert(m.values{j} == 1,'Message must be a lap stop')
                    case 'lap_trigger'
                        % fit_profile.hpp/FIT_LAP_TRIGGER
                        switch(m.values{j})
                            case 0
                                lap.Trigger = LapTrigger.Manual;
                            case 2
                                lap.Trigger = LapTrigger.Auto;
                            case 7
                                lap.Trigger = LapTrigger.End;
                            otherwise
                                warning(['Unknown lap trigger: ' num2str(m.values{j})])
                        end
                    case 'total_distance'
                        % Round to nearest meter, it helps with display and
                        % the measurement is not that precise anyways.
                        lap.Distance = round(m.values{j});
                    case {'sport','sub_sport'}
                        % do nothing, sport handled by session message
                    case {'total_ascent','total_descent',...
                            'total_calories','wkt_step_index','intensity',...
                            'avg_speed','max_speed','time_in_speed_zone','enhanced_avg_speed','enhanced_max_speed',...
                            'time_in_hr_zone','avg_heart_rate','max_heart_rate','min_heart_rate',...
                            'total_cycles','avg_cadence','max_cadence','avg_fractional_cadence','max_fractional_cadence','time_in_cadence_zone',...
                            'avg_temperature','max_temperature',...
                            'start_position_lat','start_position_long','end_position_lat','end_position_long',...
                            'Lap Power'}
                        % do nothing
                    otherwise
                        warning(['Unknown field in ' m.name ' message: ' m.fields{j}])
                end
            end
            lap.ElapsedTime = lap.StopTime-lap.StartTime;
            if isempty(lap.Trigger)
                lap.Trigger = LapTrigger.Unknown;
            end
            fit.Laps(end+1) = lap;
            
        case 'session'
            % Guaranteed to be in every activity .fit file.
            seen_session_message = true;
            for j=1:numel(m.fields)
                switch(m.fields{j})
                    case 'timestamp'
                        fit.StopTime = timestamp2datetime(m.values{j});
                    case 'start_time'
                        fit.StartTime = timestamp2datetime(m.values{j});
                    case 'total_elapsed_time'
                        fit.ElapsedTime = duration(0,0,m.values{j});
                    case 'total_timer_time'
                        fit.TimerTime = duration(0,0,m.values{j});
                    case 'total_distance'
                        fit.Distance = round(m.values{j});
                    case 'num_laps'
                        fit.NumLaps = m.values{j};
                    case 'sport'
                        % fit_profile.hpp/FIT_SPORT
                        switch (m.values{j})
                            case 1 % Running
                                % okay, do nothing
                            case 2 % Cycling
                                error('Cycling activities unsupported')
                            otherwise
                                error('Unknown sport type: %d',m.values{j})
                        end
                    case {'time_in_hr_zone','avg_heart_rate','max_heart_rate','min_heart_rate',...
                            'time_in_speed_zone','avg_speed','max_speed','enhanced_avg_speed','enhanced_max_speed',...
                            'time_in_cadence_zone','avg_cadence','max_cadence',...
                            'avg_lap_time',...
                            'total_calories',...
                            'total_ascent','total_descent','max_altitude','enhanced_max_altitude',...
                            ...
                            'start_position_lat','start_position_long','nec_lat','nec_long','swc_lat','swc_long',...
                            'total_cycles','avg_fractional_cadence','max_fractional_cadence',...
                            'message_index','first_lap_index',...
                            'event','event_type','sub_sport','trigger',...
                            'total_training_effect','total_anaerobic_training_effect',...
                            'avg_temperature','max_temperature',...
                            }
                        % do nothing
                    otherwise
                        warning(['Unknown field in ' m.name ' message: ' m.fields{j}])
                end
            end
        case 'file_creator' % do nothing
        case 'device_info' % do nothing
        case 'device_settings' % do nothing
        case 'user_profile' % do nothing
        case 'sport' % do nothing
        case 'zones_target' % do nothing
        case 'developer_data_id' % do nothing
        case 'field_description' % do nothing
        otherwise
            warning(['Unknown message type: ' m.name])
    end
end

assert(seen_file_id_message,'Must have file_id message')
assert(seen_session_message,'Must have session message')

% Build lap split times
split = duration(0,0,0);
for i=1:fit.NumLaps
    lap = fit.Laps(i);
    lap.StartSplit = split;
    split = split+lap.TimerTime;
    lap.StopSplit = split;
end

end

