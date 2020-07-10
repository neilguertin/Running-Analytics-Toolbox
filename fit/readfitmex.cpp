////////////////////////////////////////////////////////////////////////////////
// The following FIT Protocol software provided may be used with FIT protocol
// devices only and remains the copyrighted property of Garmin Canada Inc.
// The software is being provided on an "as-is" basis and as an accommodation,
// and therefore all warranties, representations, or guarantees of any kind
// (whether express, implied or statutory) including, without limitation,
// warranties of merchantability, non-infringement, or fitness for a particular
// purpose, are specifically disclaimed.
//
// Copyright 2008 Garmin Canada Inc.
////////////////////////////////////////////////////////////////////////////////

// readfitmex.cpp
// This mex function takes a filename of a .fit file and returns the contents of
// that file as close as possible to the original form. A .fit file contains a
// series of messages, each with a number of fields and corresponding values.
// This is returned to MATLAB as a struct array with the following fields:
//   name - char array - The name of the message
//   fields - cell array of char arrays - A list of names of fields in the message
//   units - cell array of char arrays - A corresponding list of units for each field
//   values - cell array of string or double arrays - A corresponding list of
//            values of each field. Most are scalars but some may be vectors.
//
// There are a few differences between the data in the .fit file and the data
// returned to MATLAB
//   Empty messages of name 'unknown' and no fields are ignored.
//     I think these are the definition messages.
//   The scale and offset provided for each field are used in the calculation
//       of values by the SDK and so do not need to be returned.
//
// This mex function uses the C++ FitSDK to do the heavy lifting. Any other
// data contained in the .fit file but not passed along to MATLAB is because
// of the SDK.

#include <fstream>
#include <iostream>
#include <string>
#include <list>
#include <vector>
#include "boost/variant.hpp"

#include "mex.hpp"
#include "mexAdapter.hpp"

#include "fit_decode.hpp"
#include "fit_mesg_broadcaster.hpp"
#include "fit_developer_field_description.hpp"

enum field_data_type {
    string_field,
    double_field,
};

struct myField {
    std::string name;
    std::string units;
    field_data_type type;
    std::vector<boost::variant<double, std::string>> values;
};

struct myMessage {
    std::string name;
    std::vector<myField> fields;
};

class MexFunction : public matlab::mex::Function {
public:
    std::list<myMessage> messages;
    
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs);
    void error(std::string const& id, std::string const& msg);
    void print(std::string const& str);
    void processMessage(fit::Mesg& mesg);
    myField processField(const fit::FieldBase& field);
    field_data_type GetType(const fit::FieldBase& field);
};

class Listener : public fit::MesgListener
               , public fit::DeveloperFieldDescriptionListener {
  public:
    MexFunction* driver;
    Listener(MexFunction* driver) : driver(driver){}
    
    void OnMesg(fit::Mesg& mesg){
        // skip empty unknown messages
        if (mesg.GetName() == "unknown"){
            return;
        }
        driver->processMessage(mesg);
    }
    
    // Required by DeveloperFieldDescriptionListener but unused
    void OnDeveloperFieldDescription( const fit::DeveloperFieldDescription& desc ) override {}
};
        
void MexFunction::operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
    
    // Argument validation performed by MATLAB wrapper
    
    fit::Decode decode;
    // decode.SkipHeader();       // Use on streams with no header and footer (stream contains FIT defn and data messages only)
    // decode.IncompleteStream(); // This suppresses exceptions with unexpected eof (also incorrect crc)
    fit::MesgBroadcaster mesgBroadcaster;
    Listener listener(this);
    mesgBroadcaster.AddListener((fit::MesgListener &)listener);
    
    // Open file
    const char* filename = matlab::data::CharArray(inputs[0]).toAscii().c_str();
//     print("Reading " + std::string(filename) + "\n");
    std::fstream file;
    file.open(filename, std::ios::in | std::ios::binary);
    if (!file.is_open()) {
        error("RAT:CouldNotOpenFile", "Error opening file.\nFilename: " + std::string(filename));
    }
    if (!decode.CheckIntegrity(file)) {
        error("RAT:IntegrityFailed", "FIT file integrity failed.\nFilename: " + std::string(filename));
    }
    
    // Decode file (Build std::list<myMessage> messages)
    try {
        decode.Read(&file, &mesgBroadcaster, &mesgBroadcaster, &listener);
    } catch (const fit::RuntimeException& e) {
        error("RAT:CouldNotDecodeFile", "Error decoding file.\nFilename: " + std::string(filename) + "\nException: " + std::string(e.what()));//e.what());
    }
    
    // Build MATLAB arrays
    matlab::data::ArrayFactory factory;
    matlab::data::StructArray S = factory.createStructArray({1,messages.size()},{"name","fields","units","values"});
    
    int i=0;
    // Process each message
    for (myMessage const& m : messages){
        matlab::data::CellArray field_names = factory.createCellArray({1,m.fields.size()});
        matlab::data::CellArray field_units = factory.createCellArray({1,m.fields.size()});
        matlab::data::CellArray field_values = factory.createCellArray({1,m.fields.size()});
        
        // Process each field
        for (int f=0; f<m.fields.size(); f++){
            field_names[f] = factory.createCharArray(m.fields[f].name);
            field_units[f] = factory.createCharArray(m.fields[f].units);
            
            // Process values
            unsigned int numel = m.fields[f].values.size();
            if (numel == 1){
                // one string
                if (m.fields[f].type == string_field){
                    field_values[f] = factory.createScalar(boost::get<std::string>(m.fields[f].values[0]));
                // one double
                } else if (m.fields[f].type == double_field){
                    field_values[f] = factory.createArray<double>({1,1},{boost::get<double>(m.fields[f].values[0])});
                }
            } else {
                // many string
                if (m.fields[f].type == string_field){
                    matlab::data::TypedArray<matlab::data::MATLABString> values = factory.createArray<matlab::data::MATLABString>({1,numel});
                    int v=0;
                    for (auto elem : values){
                        elem = boost::get<std::string>(m.fields[f].values[v]);
                        v++;
                    }
                    field_values[f] = values;
                // many double
                } else if (m.fields[f].type == double_field){
                    matlab::data::TypedArray<double> values = factory.createArray<double>({1,numel});
                    int v=0;
                    for (auto& elem : values){
                        elem = boost::get<double>(m.fields[f].values[v]);
                        v++;
                    }
                    field_values[f] = values;
                }
            }
        }
        
        S[i]["name"] = factory.createCharArray(m.name);
        S[i]["fields"] = field_names;
        S[i]["units"] = field_units;
        S[i]["values"] = field_values;
        i++;
    }
    
    outputs[0] = S;
    
}

void MexFunction::error(std::string const& id, std::string const& msg) {
    std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();
    matlab::data::ArrayFactory factory;
    matlabPtr->feval(u"error", 0, std::vector<matlab::data::Array>({ factory.createScalar(id), factory.createScalar(msg) }));
}

void MexFunction::print(std::string const& str) {
    std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();
    matlab::data::ArrayFactory factory;
    matlabPtr->feval(u"fprintf", 0, std::vector<matlab::data::Array>({ factory.createScalar(str) }));
}

void MexFunction::processMessage(fit::Mesg& mesg){

    int numFields = mesg.GetNumFields() + mesg.GetNumDevFields();
    std::vector<myField> fields;//(numFields);
    
    // Process Fields
    for (int i=0; i<mesg.GetNumFields(); i++) {
        fit::Field* field = mesg.GetFieldByIndex(i);
        fields.push_back(processField(*field));
    }
    
    // Process Developer Fields
    if (mesg.GetNumDevFields() > 0) {
        for (auto& devField : mesg.GetDeveloperFields()) {
            fields.push_back(processField(devField));
        }
    }
    
    myMessage m = {mesg.GetName(), fields};
    messages.push_back(m);
}

myField MexFunction::processField(const fit::FieldBase& field) {
    field_data_type type = GetType(field);
    
    // Only runs are supported. If this is another sport, we want to stop
    // here, which is as early as possible.
    if (field.GetName() == "sport" && field.GetFLOAT64Value(0) != 1){
        error("RAT:NotARun","Activity is not a run");
    }
    
    // values
    std::vector<boost::variant<double, std::string>> values;
    switch (type) {
        case double_field:
            for (int i=0; i<field.GetNumValues(); i++){
                values.push_back(field.GetFLOAT64Value(i));
            }
            break;
        case string_field:
            for (int i=0; i<field.GetNumValues(); i++){
                std::wstring ws(field.GetSTRINGValue(i));
                std::string ss(ws.begin(), ws.end());
                values.push_back(ss);
            }
            break;
    }
    myField f = {field.GetName(), field.GetUnits(), type, values};
    return f;
}

field_data_type MexFunction::GetType(const fit::FieldBase& field){
    switch (field.GetType()) {
        case FIT_BASE_TYPE_ENUM:
        case FIT_BASE_TYPE_BYTE:
        case FIT_BASE_TYPE_SINT8:
        case FIT_BASE_TYPE_UINT8:
        case FIT_BASE_TYPE_SINT16:
        case FIT_BASE_TYPE_UINT16:
        case FIT_BASE_TYPE_SINT32:
        case FIT_BASE_TYPE_UINT32:
        case FIT_BASE_TYPE_SINT64:
        case FIT_BASE_TYPE_UINT64:
        case FIT_BASE_TYPE_UINT8Z:
        case FIT_BASE_TYPE_UINT16Z:
        case FIT_BASE_TYPE_UINT32Z:
        case FIT_BASE_TYPE_UINT64Z:
        case FIT_BASE_TYPE_FLOAT32:
        case FIT_BASE_TYPE_FLOAT64:
            return double_field;
            break;
        case FIT_BASE_TYPE_STRING:
            return string_field;
            break;
        default:
            error("RAT:UnsupportedFieldType","Unsupported field type");
    }
}