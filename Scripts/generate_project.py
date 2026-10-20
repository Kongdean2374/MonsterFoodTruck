#!/usr/bin/env python3
"""Generate a deterministic Xcode project using only Python's standard library."""
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
objects = {}

def uid(key):
    return hashlib.sha256(key.encode()).hexdigest()[:24].upper()

def obj(key, **fields):
    ident = uid(key)
    objects[ident] = fields
    return ident

def encode(value, indent=0):
    if isinstance(value, dict):
        return "{\n" + "".join("\t"*(indent+1) + encode(k) + " = " + encode(v, indent+1) + ";\n" for k,v in value.items()) + "\t"*indent + "}"
    if isinstance(value, list):
        return "(" + ", ".join(encode(v, indent+1) for v in value) + ")"
    if isinstance(value, int):
        return str(value)
    return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"') + '"'

products, children, targets = [], [], []
project_id = uid("project")
common = {
    "SDKROOT":"iphoneos", "IPHONEOS_DEPLOYMENT_TARGET":"17.0", "SWIFT_VERSION":"5.0",
    "TARGETED_DEVICE_FAMILY":"1", "CLANG_ENABLE_MODULES":"YES", "SWIFT_EMIT_LOC_STRINGS":"NO",
    "CODE_SIGNING_ALLOWED":"NO", "CODE_SIGNING_REQUIRED":"NO", "DEVELOPMENT_TEAM":"",
    "MARKETING_VERSION":"1.0.0", "CURRENT_PROJECT_VERSION":"1", "ENABLE_USER_SCRIPT_SANDBOXING":"YES",
}

def configurations(key, settings):
    entries=[]
    for mode in ("Debug", "Release"):
        cfg = common | settings | {
            "SWIFT_OPTIMIZATION_LEVEL": "-Onone" if mode == "Debug" else "-O",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG" if mode == "Debug" else "",
            "DEBUG_INFORMATION_FORMAT": "dwarf" if mode == "Debug" else "dwarf-with-dsym",
            "ENABLE_TESTABILITY": "YES" if mode == "Debug" else "NO",
        }
        entries.append(obj(key+mode, isa="XCBuildConfiguration", buildSettings=cfg, name=mode))
    return obj(key+"configs", isa="XCConfigurationList", buildConfigurations=entries, defaultConfigurationIsVisible=0, defaultConfigurationName="Release")

for name,folder,kind in [("MonsterFoodTruck","MonsterFoodTruck","application"),("MonsterFoodTruckTests","Tests","bundle.unit-test"),("MonsterFoodTruckUITests","UITests","bundle.ui-testing")]:
    source_builds=[]
    for file in sorted((ROOT/folder).rglob("*.swift")):
        rel=str(file.relative_to(ROOT))
        ref=obj(rel,isa="PBXFileReference",lastKnownFileType="sourcecode.swift",path=rel,sourceTree="<group>")
        children.append(ref)
        source_builds.append(obj(rel+"build",isa="PBXBuildFile",fileRef=ref))
    product=obj(name+"product",isa="PBXFileReference",explicitFileType="wrapper.application" if kind=="application" else "wrapper.cfbundle",includeInIndex=0,path=name+(".app" if kind=="application" else ".xctest"),sourceTree="BUILT_PRODUCTS_DIR")
    products.append(product)
    phases=[obj(name+"sources",isa="PBXSourcesBuildPhase",buildActionMask=2147483647,files=source_builds,runOnlyForDeploymentPostprocessing=0)]
    resource_builds=[]
    if kind=="application":
        # A root directory literally named Resources makes CFBundle detect a legacy
        # macOS bundle layout. Copy ordinary resource files using standard phases.
        resource_files=[(str(f.relative_to(ROOT)), {".json":"text.json", ".png":"image.png", ".wav":"audio.wav"}.get(f.suffix,"file")) for f in sorted((ROOT/"MonsterFoodTruck/Resources").rglob("*")) if f.is_file()]
        for path,ftype in resource_files+[("MonsterFoodTruck/Assets.xcassets","folder.assetcatalog")]:
            if (ROOT/path).exists():
                ref=obj(path,isa="PBXFileReference",lastKnownFileType=ftype,path=path,sourceTree="<group>")
                children.append(ref)
                resource_builds.append(obj(path+"build",isa="PBXBuildFile",fileRef=ref))
    phases.append(obj(name+"resources",isa="PBXResourcesBuildPhase",buildActionMask=2147483647,files=resource_builds,runOnlyForDeploymentPostprocessing=0))
    settings={"PRODUCT_NAME":name,"PRODUCT_BUNDLE_IDENTIFIER":"cc.chaihome.monsterfoodtruck"+("" if kind=="application" else "."+name),"GENERATE_INFOPLIST_FILE":"YES"}
    dependencies=[]
    if kind=="application":
        settings |= {"INFOPLIST_FILE":"MonsterFoodTruck/Info.plist","GENERATE_INFOPLIST_FILE":"NO","ASSETCATALOG_COMPILER_APPICON_NAME":"AppIcon","ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME":"AccentColor","SUPPORTED_PLATFORMS":"iphoneos iphonesimulator","SUPPORTS_MACCATALYST":"NO"}
    else:
        settings |= {"TEST_TARGET_NAME":"MonsterFoodTruck"}
        if kind=="bundle.unit-test":
            settings |= {"TEST_HOST":"$(BUILT_PRODUCTS_DIR)/MonsterFoodTruck.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/MonsterFoodTruck","BUNDLE_LOADER":"$(TEST_HOST)"}
        proxy=obj(name+"proxy",isa="PBXContainerItemProxy",containerPortal=project_id,proxyType=1,remoteGlobalIDString=uid("MonsterFoodTrucktarget"),remoteInfo="MonsterFoodTruck")
        dependencies.append(obj(name+"dependency",isa="PBXTargetDependency",target=uid("MonsterFoodTrucktarget"),targetProxy=proxy))
    targets.append(obj(name+"target",isa="PBXNativeTarget",buildConfigurationList=configurations(name,settings),buildPhases=phases,buildRules=[],dependencies=dependencies,name=name,productName=name,productReference=product,productType="com.apple.product-type."+kind))

products_group=obj("products",isa="PBXGroup",children=products,name="Products",sourceTree="<group>")
group=obj("rootgroup",isa="PBXGroup",children=children+[products_group],sourceTree="<group>")
obj("project",isa="PBXProject",attributes={"LastUpgradeCheck":"1640","BuildIndependentTargetsInParallel":"YES"},buildConfigurationList=configurations("project",{}),compatibilityVersion="Xcode 14.0",developmentRegion="zh-Hant",knownRegions=["zh-Hant","en","Base"],mainGroup=group,productRefGroup=products_group,projectDirPath="",projectRoot="",targets=targets)
project=ROOT/"MonsterFoodTruck.xcodeproj"
project.mkdir(exist_ok=True)
(project/"project.pbxproj").write_text("// !$*UTF8*$!\n"+encode({"archiveVersion":1,"classes":{},"objectVersion":56,"objects":objects,"rootObject":project_id})+"\n")
scheme=project/"xcshareddata/xcschemes"
scheme.mkdir(parents=True,exist_ok=True)
def buildref(name):
    return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{uid(name+"target")}" BuildableName="{name}.{"app" if name=="MonsterFoodTruck" else "xctest"}" BlueprintName="{name}" ReferencedContainer="container:MonsterFoodTruck.xcodeproj"/>'
app=buildref("MonsterFoodTruck")
(scheme/"MonsterFoodTruck.xcscheme").write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1640" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{app}</BuildActionEntry></BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO" parallelizable="NO">{buildref("MonsterFoodTruckTests")}</TestableReference><TestableReference skipped="NO" parallelizable="NO">{buildref("MonsterFoodTruckUITests")}</TestableReference></Testables></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app}</BuildableProductRunnable></LaunchAction>
<ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{app}</BuildableProductRunnable></ProfileAction>
<AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>\n''')
print("Generated MonsterFoodTruck.xcodeproj (no external generator)")
