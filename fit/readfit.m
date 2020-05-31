function fit = readfit(filename)
% Read the .fit file given by filename and return a FitFile object
% containing all of the relevant and interesting data.
% Only running files are supported.

arguments
    filename (1,1) string
end

fit = FitFile;
fit.Filename = filename;

[metadata, data] = readfitraw(filename);

[T, units] = processData(data);

[Tnew, unitsnew] = polishData(T, units);

processMetadata(fit,metadata)

fit.Data = Tnew;
fit.Units = unitsnew;

fit.validate;
end
