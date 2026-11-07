#include "mmtTlvDemuxer.h"
#include "bonDriverContext.h"
#include <cassert>
#include <iostream>
#ifndef DANTTO4K_NO_CAS
#include "acasHandler.h"
#endif
#include <dlfcn.h>

BonDriverContext g_bonDriverContext;

namespace {

// Path of this shared object (resolved through dladdr), e.g. /opt/bon/BonDriver_dantto4k.so
std::string getModulePath() {
    Dl_info info;
    if (dladdr(reinterpret_cast<void*>(&getModulePath), &info) == 0 || !info.dli_fname) {
        return "";
    }
    return info.dli_fname;
}

// BonDriver_dantto4k.so -> BonDriver_dantto4k.ini (same directory, same base name)
std::string getConfigFilePath() {
    std::string path = getModulePath();
    size_t slash = path.find_last_of('/');
    size_t dot = path.find_last_of('.');
    if (dot == std::string::npos || (slash != std::string::npos && dot < slash)) {
        return path + ".ini";
    }
    return path.substr(0, dot) + ".ini";
}

std::string getModuleDir() {
    std::string path = getModulePath();
    size_t slash = path.find_last_of('/');
    if (slash == std::string::npos) {
        return "";
    }
    return path.substr(0, slash + 1);
}


}

#define DANTTO4K_EXPORT __attribute__((visibility("default")))

extern "C" DANTTO4K_EXPORT IBonDriver* CreateBonDriver() {
    std::string path = getConfigFilePath();

    try {
        config = loadConfig(path);
    }
    catch (const std::runtime_error& e) {
        std::cerr << e.what() << std::endl;
        return nullptr;
    }

    // A bare file name ("BonDriver_xxx.so") is looked up next to this .so first,
    // the way LoadLibrary does it on Windows. Paths with a '/' are used as written.
    if (!config.bondriverPath.empty() && config.bondriverPath.find('/') == std::string::npos) {
        config.bondriverPath = getModuleDir() + config.bondriverPath;
    }

    g_bonDriverContext.handler.setOutputCallback([&](const uint8_t* data, size_t size) {
        assert(size == 188);
        g_bonDriverContext.remuxOutput.insert(g_bonDriverContext.remuxOutput.end(), data, data + size);
    });
    g_bonDriverContext.demuxer.setDemuxerHandler(g_bonDriverContext.handler);
    if (!g_bonDriverContext.bonTuner.init()) {
        return nullptr;
    }

    return &g_bonDriverContext.bonTuner;
}
