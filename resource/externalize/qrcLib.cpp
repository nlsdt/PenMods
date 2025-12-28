#include "../models/YDP02X/qrc_qml.h"

extern "C" {
const unsigned char* get_qt_resource_struct(){
    return qt_resource_struct;
};
const unsigned char* get_qt_resource_data(){
    return qt_resource_data;
};
const unsigned char* get_qt_resource_name(){
    return qt_resource_name;
};
}