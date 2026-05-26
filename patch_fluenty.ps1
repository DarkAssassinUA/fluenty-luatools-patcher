param (
    [string]$Action,
    [string]$SourcePath
)

# Set console output and input to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$PATCHER_VERSION = "1.0"
$SUPPORTED_FLUENTY_VERSION = "1.14.0"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host (([char[]](32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,76,117,97,84,111,111,108,115,32,1076,1083,1103,32,77,105,108,108,101,110,105,117,109,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32) -join "")) -ForegroundColor Cyan
Write-Host (([char[]](32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,1042,1077,1088,1089,1080,1103,32,1087,1072,1090,1095,1077,1088,1072,58,32) -join "") + $PATCHER_VERSION) -ForegroundColor Cyan
Write-Host (([char[]](32,32,32,32,32,32,1040,1074,1090,1086,1088,58,32,76,101,32,77,97,120,105,109,101,32,40,116,46,109,101,47,108,101,109,97,120,105,109,101,41,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32) -join "")) -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$steam_skin_path = "C:\Program Files (x86)\Steam\steamui\skins\fluenty"
$local_workspace_path = "g:\work\fluenty"

$script_dir = $null
if ($MyInvocation.MyCommand -and $MyInvocation.MyCommand.Path) {
    $script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if ([string]::IsNullOrEmpty($script_dir)) {
    $script_dir = $PSScriptRoot
}
if ([string]::IsNullOrEmpty($script_dir)) {
    $script_dir = (Get-Location).Path
}
$sibling_path = Join-Path $script_dir "fluenty"

# Interactive Menu to choose action
$action_choice = $Action
if ([string]::IsNullOrEmpty($action_choice)) {
    Write-Host (([char[]](10,1042,1099,1073,1077,1088,1080,1090,1077,32,1076,1077,1081,1089,1090,1074,1080,1077,58) -join "")) -ForegroundColor Cyan
    Write-Host (([char[]](91,49,93,32,1055,1088,1086,1087,1072,1090,1095,1080,1090,1100,32,1091,1089,1090,1072,1085,1086,1074,1083,1077,1085,1085,1091,1102,32,1090,1077,1084,1091,32,70,108,117,101,110,116,121,32,40,1083,1086,1082,1072,1083,1100,1085,1086,41) -join ""))
    Write-Host (([char[]](91,50,93,32,1059,1089,1090,1072,1085,1086,1074,1080,1090,1100,32,1090,1077,1084,1091,32,70,108,117,101,110,116,121,32,1080,1079,32,1083,1086,1082,1072,1083,1100,1085,1086,1081,32,1087,1072,1087,1082,1080,32,1080,32,1087,1088,1086,1087,1072,1090,1095,1080,1090,1100) -join ""))
    $choice = Read-Host (([char[]](1042,1074,1077,1076,1080,1090,1077,32,1085,1086,1084,1077,1088,32,1076,1077,1081,1089,1090,1074,1080,1103,32,40,49,32,1080,1083,1080,32,50,41,58,32) -join ""))
    if ($choice -eq "1") {
        $action_choice = "Patch"
    } elseif ($choice -eq "2") {
        $action_choice = "Install"
    } else {
        Write-Host (([char[]](1053,1077,1074,1077,1088,1085,1099,1081,32,1074,1099,1073,1086,1088,46,32,1042,1099,1093,1086,1076,46) -join "")) -ForegroundColor Red
        Read-Host (([char[]](10,1053,1072,1078,1084,1080,1090,1077,32,69,110,116,101,114,32,1076,1083,1103,32,1074,1099,1093,1086,1076,1072,46,46,46) -join ""))
        Exit
    }
}

$source_dir = $SourcePath
if ($action_choice -eq "Install" -and [string]::IsNullOrEmpty($source_dir)) {
    $input_path = Read-Host (([char[]](1042,1074,1077,1076,1080,1090,1077,32,1087,1091,1090,1100,32,1082,32,1080,1089,1093,1086,1076,1085,1086,1081,32,1087,1072,1087,1082,1077,32,1090,1077,1084,1099,32,70,108,117,101,110,116,121,32,91,67,58,92,85,115,101,114,115,92,109,92,68,111,119,110,108,111,97,100,115,92,116,101,115,116,92,102,108,117,101,110,116,121,93,58,32) -join ""))
    if ([string]::IsNullOrEmpty($input_path)) {
        $source_dir = "C:\Users\m\Downloads\test\fluenty"
    } else {
        $source_dir = $input_path
    }
}

$theme_dir = $null

if ($action_choice -eq "Install") {
    $theme_dir = $steam_skin_path
} else {
    if (Test-Path $steam_skin_path) {
        $theme_dir = $steam_skin_path
    } elseif (Test-Path $local_workspace_path) {
        $theme_dir = $local_workspace_path
    } elseif (Test-Path $sibling_path) {
        $theme_dir = $sibling_path
    } else {
        $potential_path = Join-Path $PSScriptRoot "fluenty"
        if (Test-Path $potential_path) {
            $theme_dir = $potential_path
        }
    }
}

$css_code_file = Join-Path $script_dir "quick-css-code.css"

if ($null -eq $theme_dir) {
    Write-Host (([char[]](1054,1064,1048,1041,1050,1040,58,32,1044,1080,1088,1077,1082,1090,1086,1088,1080,1103,32,1090,1077,1084,1099,32,70,108,117,101,110,116,121,32,1085,1077,32,1085,1072,1081,1076,1077,1085,1072,33) -join "")) -ForegroundColor Red
    Write-Host (([char[]](1059,1073,1077,1076,1080,1090,1077,1089,1100,44,32,1095,1090,1086,32,1090,1077,1084,1072,32,1091,1089,1090,1072,1085,1086,1074,1083,1077,1085,1072,32,1087,1086,32,1086,1076,1085,1086,1084,1091,32,1080,1079,32,1087,1091,1090,1077,1081,58) -join ""))
    Write-Host "  - $steam_skin_path"
    Write-Host (([char[]](32,32,45,32,1080,1083,1080,32,1087,1072,1087,1082,1072,32,39,102,108,117,101,110,116,121,39,32,1085,1072,1093,1086,1076,1080,1090,1089,1103,32,1088,1103,1076,1086,1084,32,1089,32,1101,1090,1080,1084,32,1087,1072,1090,1095,1077,1088,1086,1084,46) -join ""))
    Read-Host (([char[]](10,1053,1072,1078,1084,1080,1090,1077,32,69,110,116,101,114,32,1076,1083,1103,32,1074,1099,1093,1086,1076,1072,46,46,46) -join ""))
    Exit 1
}

# 1. Ask for confirmation before starting installation (to prevent instant closing)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Read-Host (([char[]](1053,1072,1078,1084,1080,1090,1077,32,69,110,116,101,114,32,1076,1083,1103,32,1085,1072,1095,1072,1083,1072,32,1091,1089,1090,1072,1085,1086,1074,1082,1080,46,46,46) -join ""))
}

# 2. Check admin privileges before proceeding and elevate if needed
if (-not $isAdmin -and $theme_dir.StartsWith("C:\Program Files", [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Host (([char[]](1044,1083,1103,32,1084,1086,1076,1080,1092,1080,1082,1072,1094,1080,1080,32,1092,1072,1081,1083,1086,1074,32,1090,1077,1084,1099,32,1074,32,80,114,111,103,114,97,109,32,70,105,108,101,115,32,1090,1088,1077,1073,1091,1102,1090,1089,1103,32,1087,1088,1072,1074,1072,32,1072,1076,1084,1080,1085,1080,1089,1090,1088,1072,1090,1086,1088,1072,46) -join "")) -ForegroundColor Yellow
    Write-Host (([char[]](1055,1077,1088,1077,1079,1072,1087,1091,1089,1082,32,1086,1090,32,1080,1084,1077,1085,1080,32,1072,1076,1084,1080,1085,1080,1089,1090,1088,1072,1090,1086,1088,1072,46,46,46) -join "")) -ForegroundColor Yellow
    
    if ($PSCommandPath) {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Action $action_choice -SourcePath `"$source_dir`"" -Verb RunAs
    } else {
        $online_cmd = "`$Action='$action_choice'; `$SourcePath='$source_dir'; irm https://raw.githubusercontent.com/DarkAssassinUA/fluenty-luatools-patcher/main/patch_fluenty.ps1 | iex"
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$online_cmd`"" -Verb RunAs
    }
    Exit
}

# 3. If action is Install, copy theme from source folder
if ($action_choice -eq "Install") {
    if (-not (Test-Path $source_dir)) {
        Write-Host (([char[]](1054,1064,1048,1041,1050,1040,58,32,1048,1089,1093,1086,1076,1085,1072,1103,32,1087,1072,1087,1082,1072,32,1090,1077,1084,1099,32,1085,1077,32,1085,1072,1081,1076,1077,1085,1072,58,32) -join "") + $source_dir) -ForegroundColor Red
        Read-Host (([char[]](10,1053,1072,1078,1084,1080,1090,1077,32,69,110,116,101,114,32,1076,1083,1103,32,1074,1099,1093,1086,1076,1072,46,46,46) -join ""))
        Exit
    }

    Write-Host (([char[]](1050,1086,1087,1080,1088,1086,1074,1072,1085,1080,1077,32,1092,1072,1081,1083,1086,1074,32,1090,1077,1084,1099,32,1080,1079,32,1083,1086,1082,1072,1083,1100,1085,1086,1081,32,1087,1072,1087,1082,1080,46,46,46) -join "")) -ForegroundColor Cyan
    try {
        if (Test-Path $theme_dir) {
            Remove-Item -Recurse -Force $theme_dir -ErrorAction Stop
        }
        New-Item -ItemType Directory -Force -Path $theme_dir -ErrorAction Stop | Out-Null
        Copy-Item -Path "$source_dir\*" -Destination $theme_dir -Recurse -Force -ErrorAction Stop

        Write-Host (([char[]](1058,1077,1084,1072,32,70,108,117,101,110,116,121,32,1091,1089,1087,1077,1096,1085,1086,32,1089,1082,1086,1087,1080,1088,1086,1074,1072,1085,1072,32,1080,32,1091,1089,1090,1072,1085,1086,1074,1083,1077,1085,1072,33) -join "")) -ForegroundColor Green
    } catch {
        Write-Host (([char[]](1054,1096,1080,1073,1082,1072,32,1087,1088,1080,32,1082,1086,1087,1080,1088,1086,1074,1072,1085,1080,1080,32,1090,1077,1084,1099,58,32) -join "") + $_) -ForegroundColor Red
        Read-Host (([char[]](10,1053,1072,1078,1084,1080,1090,1077,32,69,110,116,101,114,32,1076,1083,1103,32,1074,1099,1093,1086,1076,1072,46,46,46) -join ""))
        Exit
    }
}

Write-Host (([char[]](1040,1082,1090,1080,1074,1085,1072,1103,32,1087,1072,1087,1082,1072,32,1090,1077,1084,1099,32,1086,1073,1085,1072,1088,1091,1078,1077,1085,1072,58,10) -join "") + $theme_dir + "`r`n") -ForegroundColor Green

# 4. Check installed theme version
$installed_version = $null
$skin_json_path = Join-Path $theme_dir "skin.json"
if (Test-Path $skin_json_path) {
    try {
        $skin_data = Get-Content -Raw -Path $skin_json_path | ConvertFrom-Json
        $installed_version = $skin_data.version
    } catch {
        # Fallback regex check if JSON parsing fails
        $skin_text = Get-Content -Raw -Path $skin_json_path
        if ($skin_text -match '"version"\s*:\s*"([^"]+)"') {
            $installed_version = $Matches[1]
        }
    }
}

Write-Host (([char[]](1055,1086,1076,1076,1077,1088,1078,1080,1074,1072,1077,1084,1072,1103,32,1074,1077,1088,1089,1080,1103,32,1090,1077,1084,1099,32,70,108,117,101,110,116,121,58,32) -join "") + $SUPPORTED_FLUENTY_VERSION) -ForegroundColor Gray
if ($installed_version) {
    Write-Host (([char[]](1059,1089,1090,1072,1085,1086,1074,1083,1077,1085,1085,1072,1103,32,1074,1077,1088,1089,1080,1103,32,1090,1077,1084,1099,32,70,108,117,101,110,116,121,58,32) -join "") + $installed_version) -ForegroundColor Green
    if ($installed_version -ne $SUPPORTED_FLUENTY_VERSION) {
        Write-Host (([char[]](10,91,1042,1053,1048,1052,1040,1053,1048,1045,93,32,1042,1077,1088,1089,1080,1103,32,1091,1089,1090,1072,1085,1086,1074,1083,1077,1085,1085,1086,1081,32,1090,1077,1084,1099,32,40) -join "") + $installed_version + ([char[]](41,32,1086,1090,1083,1080,1095,1072,1077,1090,1089,1103,32,1086,1090,32,1087,1086,1076,1076,1077,1088,1078,1080,1074,1072,1077,1084,1086,1081,32,40) -join "") + $SUPPORTED_FLUENTY_VERSION + ([char[]](41,33) -join "")) -ForegroundColor Yellow
        Write-Host (([char[]](1053,1077,32,1075,1072,1088,1072,1085,1090,1080,1088,1091,1077,1090,1089,1103,32,1082,1086,1088,1088,1077,1082,1090,1085,1072,1103,32,1088,1072,1073,1086,1090,1072,32,1087,1072,1090,1095,1077,1081,32,1085,1072,32,1101,1090,1086,1081,32,1074,1077,1088,1089,1080,1080,46) -join "")) -ForegroundColor Yellow
        $choice = Read-Host (([char[]](1042,1099,32,1074,1089,1105,32,1088,1072,1074,1085,1086,32,1093,1086,1090,1080,1090,1077,32,1087,1088,1086,1076,1086,1083,1078,1080,1090,1100,63,32,40,89,47,78,41) -join ""))
        if ($choice -notmatch '^(y|yes|d|da)$') {
            Write-Host (([char[]](1054,1087,1077,1088,1072,1094,1080,1103,32,1086,1090,1084,1077,1085,1077,1085,1072,32,1087,1086,1083,1100,1079,1086,1074,1072,1090,1077,1083,1077,1084,46) -join "")) -ForegroundColor Red
            Read-Host (([char[]](10,1053,1072,1078,1084,1080,1090,1077,32,69,110,116,101,114,32,1076,1083,1103,32,1074,1099,1093,1086,1076,1072,46,46,46) -join ""))
            Exit
        }
        Write-Host ""
    }
} else {
    Write-Host (([char[]](1059,1089,1090,1072,1085,1086,1074,1083,1077,1085,1085,1072,1103,32,1074,1077,1088,1089,1080,1103,32,1090,1077,1084,1099,32,70,108,117,101,110,116,121,58,32,1085,1077,32,1086,1087,1088,1077,1076,1077,1083,1077,1085,1072,32,40,1092,1072,1081,1083,32,115,107,105,110,46,106,115,111,110,32,1086,1090,1089,1091,1090,1089,1090,1074,1091,1077,1090,32,1080,1083,1080,32,1087,1086,1074,1088,1077,1078,1076,1077,1085,41) -join "")) -ForegroundColor Yellow
}

# -------------------------------------------------------------------------
# STEP 1: DYNAMIC JS INJECTIONS
# -------------------------------------------------------------------------
Write-Host (([char[]](91,1064,1040,1043,32,49,93,32,1042,1099,1087,1086,1083,1085,1077,1085,1080,1077,32,1076,1080,1085,1072,1084,1080,1095,1077,1089,1082,1080,1093,32,74,83,45,1080,1085,1098,1077,1082,1094,1080,1081,46,46,46) -join ""))
Start-Sleep -Milliseconds 300

$sidebar_path = Join-Path $theme_dir "src\scripts\components\sidebar.js"
$sidebar_success = $false

if (Test-Path $sidebar_path) {
    try {
        $content = [System.IO.File]::ReadAllText($sidebar_path, [System.Text.Encoding]::UTF8)

        $translations = @{
            'title="Go back"' = 'title="' + ([char[]](1053,1072,1079,1072,1076) -join "") + '"'
            'title="Store"' = 'title="' + ([char[]](1052,1072,1075,1072,1079,1080,1085) -join "") + '"'
            'text">Store</div>' = 'text">' + ([char[]](1052,1072,1075,1072,1079,1080,1085) -join "") + '</div>'
            'title="Library"' = 'title="' + ([char[]](1041,1080,1073,1083,1080,1086,1090,1077,1082,1072) -join "") + '"'
            'text">Library</div>' = 'text">' + ([char[]](1041,1080,1073,1083,1080,1086,1090,1077,1082,1072) -join "") + '</div>'
            'title="Collections"' = 'title="' + ([char[]](1050,1086,1083,1083,1077,1082,1094,1080,1080) -join "") + '"'
            'text">Collections</div>' = 'text">' + ([char[]](1050,1086,1083,1083,1077,1082,1094,1080,1080) -join "") + '</div>'
            'title="Community"' = 'title="' + ([char[]](1057,1086,1086,1073,1097,1077,1089,1090,1074,1086) -join "") + '"'
            'text">Community</div>' = 'text">' + ([char[]](1057,1086,1086,1073,1097,1077,1089,1090,1074,1086) -join "") + '</div>'
            'title="Market"' = 'title="' + ([char[]](1058,1086,1088,1075,1086,1074,1072,1103,32,1087,1083,1086,1097,1072,1076,1082,1072) -join "") + '"'
            'text">Market</div>' = 'text">' + ([char[]](1058,1086,1088,1075,1086,1074,1072,1103,32,1087,1083,1086,1097,1072,1076,1082,1072) -join "") + '</div>'
            'title="Activity"' = 'title="' + ([char[]](1040,1082,1090,1080,1074,1085,1086,1089,1090,1100) -join "") + '"'
            'text">Activity</div>' = 'text">' + ([char[]](1040,1082,1090,1080,1074,1085,1086,1089,1090,1100) -join "") + '</div>'
            'title="Downloads"' = 'title="' + ([char[]](1047,1072,1075,1088,1091,1079,1082,1080) -join "") + '"'
            'text">Downloads</div>' = 'text">' + ([char[]](1047,1072,1075,1088,1091,1079,1082,1080) -join "") + '</div>'
            'title="Friends"' = 'title="' + ([char[]](1044,1088,1091,1100,1103) -join "") + '"'
            'text">Friends</div>' = 'text">' + ([char[]](1044,1088,1091,1100,1103) -join "") + '</div>'
            'title="Settings"' = 'title="' + ([char[]](1053,1072,1089,1090,1088,1086,1081,1082,1080) -join "") + '"'
            'text">Settings</div>' = 'text">' + ([char[]](1053,1072,1089,1090,1088,1086,1081,1082,1080) -join "") + '</div>'
        }

        foreach ($eng in $translations.Keys) {
            $content = $content.Replace($eng, $translations[$eng])
        }

        # Inject LuaTools sidebar HTML if missing
        if ($content -notlike '*id="luatools-sidebar-btn"*') {
            $nas = ([char[]](1053,1072,1089,1090,1088,1086,1081,1082,1080) -join "")
            $old_section_pattern = '(?s)<div title="' + $nas + '" class="button" id="settings">\s*<div class="icon"></div>\s*<div class="text">' + $nas + '</div>\s*</div>'
            $new_section = "<div title=`"$nas`" class=`"button`" id=`"settings`">`r`n`t`t`t`t<div class=`"icon`"></div>`r`n`t`t`t`t<div class=`"text`">$nas</div>`r`n`t`t`t</div>`r`n`t`t`t<div title=`"LuaTools`" class=`"button`" id=`"luatools-sidebar-btn`" style=`"display: none;`">`r`n`t`t`t`t<div class=`"icon`"></div>`r`n`t`t`t`t<div class=`"text`">LuaTools</div>`r`n`t`t`t</div>"
            $content = [regex]::Replace($content, $old_section_pattern, $new_section)
        }

        # Inject LuaTools event listener if missing
        if ($content -notlike '*LuaTools Integration*') {
            $old_listener = "sideBarDiv.querySelector('#settings').addEventListener('click', () => window.opener.open('steam://open/settings'));"
            $new_listener = @'
sideBarDiv.querySelector('#settings').addEventListener('click', () => window.opener.open('steam://open/settings'));

		// LuaTools Integration
		const luatoolsSidebarBtn = sideBarDiv.querySelector('#luatools-sidebar-btn');
		if (luatoolsSidebarBtn) {
			luatoolsSidebarBtn.addEventListener('click', () => {
				const luatoolsHeader = document.querySelector('.luatools-header-button');
				if (luatoolsHeader) {
					luatoolsHeader.click();
				}
			});

			// Setup an interval to auto-detect if LuaTools settings button exists and make sidebar button visible
			setInterval(() => {
				const luatoolsHeader = document.querySelector('.luatools-header-button');
				if (luatoolsHeader) {
					luatoolsSidebarBtn.style.display = 'flex';
				} else {
					luatoolsSidebarBtn.style.display = 'none';
				}
			}, 1000);
		}
'@
            $content = $content.Replace($old_listener, $new_listener)
        }

        [System.IO.File]::WriteAllText($sidebar_path, $content, [System.Text.Encoding]::UTF8)
        Write-Host (([char[]](32,32,91,43,93,32,1060,1072,1081,1083,32,115,105,100,101,98,97,114,46,106,115,32,1091,1089,1087,1077,1096,1085,1086,32,1087,1077,1088,1077,1074,1077,1076,1077,1085,32,1080,32,1087,1088,1086,1087,1072,1090,1095,1077,1085,33) -join "")) -ForegroundColor Green
        $sidebar_success = $true
    } catch {
        Write-Host (([char[]](32,32,91,45,93,32,1053,1077,32,1091,1076,1072,1083,1086,1089,1100,32,1087,1088,1086,1087,1072,1090,1095,1080,1090,1100,32,115,105,100,101,98,97,114,46,106,115,58,32) -join "") + $_) -ForegroundColor Red
    }
} else {
    Write-Host (([char[]](32,32,91,45,93,32,1060,1072,1081,1083,32,115,105,100,101,98,97,114,46,106,115,32,1085,1077,32,1085,1072,1081,1076,1077,1085,32,1087,1086,32,1087,1091,1090,1080,58,32) -join "") + $sidebar_path) -ForegroundColor Yellow
}

$viewgame_path = Join-Path $theme_dir "src\styles\webkit\viewGame.js"
$viewgame_success = $false

if (Test-Path $viewgame_path) {
    try {
        $content = [System.IO.File]::ReadAllText($viewgame_path, [System.Text.Encoding]::UTF8)

        # Wrap game title if missing
        if ($content -notlike '*customGameTitleHeader*') {
            $old_title = '<div class="customGameTitle">${gameName}</div>'
            $new_title = @'
<div class="customGameTitleHeader">
								<div class="customGameTitle">${gameName}</div>
								<div class="customGameButtons steamdb-buttons" data-steamdb-buttons=""></div>
							</div>
'@
            $content = $content.Replace($old_title, $new_title)
        }

        # Inject relocator if missing
        if ($content -notlike '*LuaTools Integration*') {
            $old_pattern = '(?s)Millennium\.findElement\(document, ''\.customGameTags\.reviews''\)\.then\(\(\) => \{.*?\}\);\s*\}\);\s*\}\);'
            $relocator_code = @'
Millennium.findElement(document, '.customGameTags.reviews').then(() => {
		document.querySelector('.customGameTags.reviews').addEventListener('click', () => {
			window.scrollTo({
				top: document.querySelector('.user_reviews_header').getBoundingClientRect().top - 30,
				behavior: 'smooth',
			});
		});
	});

	// --- LuaTools Integration (Dynamic Injection) ---
	Millennium.findElement(document, '.page_title_area.game_title_area.page_content').then((elements) => {
		const activeElement = Array.from(elements).find(el => el.getBoundingClientRect().height > 0) || elements[elements.length - 1];

		// Neutralize old buttons to prevent SPA conflicts
		document.querySelectorAll('.luatools-button, .luatools-restart-button').forEach((btn) => {
			if (!activeElement.contains(btn)) {
				btn.classList.remove('luatools-button', 'luatools-restart-button');
				btn.classList.add('luatools-button-old', 'luatools-restart-button-old');
				btn.style.display = 'none';
			}
		});

		// Trigger LuaTools build
		const triggerLuaToolsBuild = () => {
			window.__LuaToolsButtonInserted = false;
			window.__LuaToolsRestartInserted = false;
			window.__LuaToolsPresenceCheckInFlight = false;
			window.__LuaToolsPresenceCheckAppId = undefined;
			window.__LuaToolsLastUrl = '';
			const triggerDiv = document.createElement('div');
			triggerDiv.className = 'steamdb-buttons';
			triggerDiv.style.display = 'none';
			document.body.appendChild(triggerDiv);
			setTimeout(() => { try { triggerDiv.remove(); } catch(_) {} }, 50);
		};
		triggerLuaToolsBuild();
		setTimeout(triggerLuaToolsBuild, 300);
		setTimeout(triggerLuaToolsBuild, 800);
		setTimeout(triggerLuaToolsBuild, 1500);

		// Relocator loop
		const intervalId = setInterval(() => {
			if (!activeElement.isConnected) {
				clearInterval(intervalId);
				return;
			}
			const target = activeElement.querySelector('.customGameButtons');
			if (!target) return;

			// Purify class collision
			const wrongBtn = activeElement.querySelector('.luatools-button.luatools-restart-button');
			if (wrongBtn) wrongBtn.classList.remove('luatools-restart-button');

			function findBtn(selector) {
				const local = activeElement.querySelector(selector);
				if (local) return local;
				const global = document.querySelector(selector);
				if (!global) return null;
				const otherPage = global.closest('.page_title_area.game_title_area.page_content');
				if (otherPage && otherPage !== activeElement) return null;
				return global;
			}

			const luatoolsBtn = findBtn('.luatools-button');
			if (luatoolsBtn && luatoolsBtn.parentElement !== target) {
				target.insertBefore(luatoolsBtn, target.firstChild);
			}

			const restartBtn = findBtn('.luatools-restart-button');
			if (restartBtn && restartBtn.parentElement !== target) {
				target.appendChild(restartBtn);
			}

			const steamdbBtn = findBtn('.apphub_OtherSiteInfo a[href*="steamdb.info"]');
			if (steamdbBtn && steamdbBtn.parentElement !== target) {
				target.appendChild(steamdbBtn);
			}

			if (luatoolsBtn && restartBtn && target.contains(luatoolsBtn) && target.contains(restartBtn)) {
				const children = Array.from(target.children);
				if (children.indexOf(luatoolsBtn) > children.indexOf(restartBtn)) {
					target.insertBefore(luatoolsBtn, restartBtn);
				}
			}

			if (restartBtn) {
				const hasAddBtn = !(!target.querySelector('.luatools-button'));
				restartBtn.style.display = hasAddBtn ? 'none' : '';
			}
		}, 250);
	});
'@
            $content = [regex]::Replace($content, $old_pattern, $relocator_code)
        }

        [System.IO.File]::WriteAllText($viewgame_path, $content, [System.Text.Encoding]::UTF8)
        Write-Host (([char[]](32,32,91,43,93,32,1060,1072,1081,1083,32,118,105,101,119,71,97,109,101,46,106,115,32,1091,1089,1087,1077,1096,1085,1086,32,1087,1088,1086,1087,1072,1090,1095,1077,1085,33) -join "")) -ForegroundColor Green
        $viewgame_success = $true
    } catch {
        Write-Host (([char[]](32,32,91,45,93,32,1053,1077,32,1091,1076,1072,1083,1086,1089,1100,32,1087,1088,1086,1087,1072,1090,1095,1080,1090,1100,32,118,105,101,119,71,97,109,101,46,106,115,58,32) -join "") + $_) -ForegroundColor Red
    }
} else {
    Write-Host (([char[]](32,32,91,45,93,32,1060,1072,1081,1083,32,118,105,101,119,71,97,109,101,46,106,115,32,1085,1077,32,1085,1072,1081,1076,1077,1085,32,1087,1086,32,1087,1091,1090,1080,58,32) -join "") + $viewgame_path) -ForegroundColor Yellow
}

if ($sidebar_success -and $viewgame_success) {
    Write-Host (([char[]](10,91,1059,1057,1055,1045,1061,93,32,1064,1040,1043,32,49,32,1047,1040,1042,1045,1056,1064,1045,1053,33,32,74,83,45,1092,1072,1081,1083,1099,32,1091,1089,1087,1077,1096,1085,1086,32,1087,1077,1088,1077,1074,1077,1076,1077,1085,1099,32,1080,32,1084,1086,1076,1080,1092,1080,1094,1080,1088,1086,1074,1072,1085,1099,46,10) -join "")) -ForegroundColor Green
} else {
    Write-Host (([char[]](10,91,1042,1053,1048,1052,1040,1053,1048,1045,93,32,1064,1040,1043,32,49,32,1047,1040,1042,1045,1056,1064,1045,1053,32,1057,32,1054,1064,1048,1041,1050,1040,1052,1048,46,32,1055,1088,1086,1074,1077,1088,1100,1090,1077,32,1089,1086,1086,1073,1097,1077,1085,1080,1103,32,1074,1099,1096,1077,46,10) -join "")) -ForegroundColor Yellow
}

# -------------------------------------------------------------------------
# STEP 2: CREATE QUICK CSS AND COPY TO CLIPBOARD
# -------------------------------------------------------------------------
Write-Host (([char[]](91,1064,1040,1043,32,50,93,32,1055,1086,1076,1075,1086,1090,1086,1074,1082,1072,32,1089,1090,1080,1083,1077,1081,32,81,117,105,99,107,32,67,83,83,46,46,46) -join ""))
Start-Sleep -Milliseconds 300

$css_content = @'
/* --- LuaTools Sidebar Icon --- */
.section #luatools-sidebar-btn.button .icon::before {
	content: '\e0a0' !important;
}
.section #luatools-sidebar-btn.button:active .icon::before {
	content: '\e0a1' !important;
}

/* --- Game Title Header & Buttons --- */
.customGameTitleHeader {
	position: relative !important;
	display: flex !important;
	align-items: center !important;
	gap: 16px !important;
	flex-wrap: wrap !important;
	padding-top: 26px !important;
}

.customGameButtons .luatools-button,
.customGameButtons .luatools-button:hover,
.customGameButtons .luatools-button:focus,
.customGameButtons .luatools-button:active {
	position: static !important;
	display: inline-flex !important;
	align-items: center !important;
}

.customGameButtons .luatools-button:hover,
.customGameButtons .luatools-button.active-focus,
.customGameButtons .luatools-restart-button:hover,
.customGameButtons .luatools-restart-button.active-focus {
	transform: none !important;
}

.customGameButtons .luatools-pills-container {
	position: absolute !important;
	top: 4px !important;
	left: 0 !important;
	transform: none !important;
	display: inline-flex !important;
	gap: 6px !important;
	align-items: center !important;
	pointer-events: none !important;
	white-space: nowrap !important;
	z-index: 5 !important;
}

.customGameButtons .luatools-pill {
	padding: 3px 8px !important;
	border-radius: 4px !important;
	font-size: 10px !important;
	font-weight: 700 !important;
	text-transform: uppercase !important;
	letter-spacing: 0.6px !important;
	display: inline-flex !important;
	align-items: center !important;
	height: 18px !important;
	line-height: 1 !important;
	box-shadow: 0 1px 4px rgba(0,0,0,0.3) !important;
	cursor: default !important;
}

.customGameTitle {
	font-size: 36px !important;
	letter-spacing: normal !important;
	font-weight: 500 !important;
	color: white !important;
}

.customGameButtons {
	display: flex !important;
	align-items: center !important;
	gap: 8px !important;
}

.customGameButtons a {
	background: rgba(255, 255, 255, 0.08) !important;
	border: 1px solid rgba(255, 255, 255, 0.15) !important;
	border-radius: 6px !important;
	color: #e5e5e5 !important;
	padding: 6px 14px !important;
	font-size: 13px !important;
	font-weight: 500 !important;
	text-decoration: none !important;
	display: inline-flex !important;
	align-items: center !important;
	justify-content: center !important;
	height: 32px !important;
	box-sizing: border-box !important;
	transition: all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1) !important;
	cursor: pointer !important;
}

.customGameButtons a:hover {
	background: rgba(255, 255, 255, 0.14) !important;
	border-color: rgba(255, 255, 255, 0.25) !important;
	color: white !important;
	transform: translateY(-1px) !important;
}

.customGameButtons a:active {
	transform: translateY(0) !important;
}

.customGameButtons a span {
	font-size: 13px !important;
	font-weight: 500 !important;
}

.customGameButtons .luatools-restart-button {
	display: none !important;
}
.customGameButtons:not(:has(.luatools-button)) .luatools-restart-button {
	display: inline-flex !important;
}
'@

try {
    [System.IO.File]::WriteAllText($css_code_file, $css_content, [System.Text.Encoding]::UTF8)
    Write-Host (([char[]](32,32,91,43,93,32,1057,1090,1080,1083,1080,32,81,117,105,99,107,32,67,83,83,32,1089,1086,1093,1088,1072,1085,1077,1085,1099,32,1074,32,1092,1072,1081,1083,58,32) -join "") + $css_code_file) -ForegroundColor Green
} catch {
    Write-Host (([char[]](32,32,91,45,93,32,1053,1077,32,1091,1076,1072,1083,1086,1089,1100,32,1079,1072,1087,1080,1089,1072,1090,1100,32,67,83,83,45,1092,1072,1081,1083,58,32) -join "") + $_) -ForegroundColor Red
}

try {
    Set-Clipboard -Value $css_content -ErrorAction Stop
    Write-Host (([char[]](32,32,91,43,93,32,1050,1086,1076,32,1089,1090,1080,1083,1077,1081,32,1040,1042,1058,1054,1052,1040,1058,1048,1063,1045,1057,1050,1048,32,1089,1082,1086,1087,1080,1088,1086,1074,1072,1085,32,1074,32,1073,1091,1092,1077,1088,32,1086,1073,1084,1077,1085,1072,32,87,105,110,100,111,119,115,33) -join "")) -ForegroundColor Green
} catch {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::SetText($css_content)
        Write-Host (([char[]](32,32,91,43,93,32,1050,1086,1076,32,1089,1090,1080,1083,1077,1081,32,1040,1042,1058,1054,1052,1040,1058,1048,1063,1045,1057,1050,1048,32,1089,1082,1086,1087,1080,1088,1086,1074,1072,1085,32,1074,32,1073,1091,1092,1077,1088,32,1086,1073,1084,1077,1085,1072,32,87,105,110,100,111,119,115,33) -join "")) -ForegroundColor Green
    } catch {
        Write-Host (([char[]](32,32,91,45,93,32,1053,1077,32,1091,1076,1072,1083,1086,1089,1100,32,1089,1082,1086,1087,1080,1088,1086,1074,1072,1090,1100,32,1082,1086,1076,32,1072,1074,1090,1086,1084,1072,1090,1080,1095,1077,1089,1082,1080,46,32,1042,1099,32,1084,1086,1078,1077,1090,1077,32,1089,1082,1086,1087,1080,1088,1086,1074,1072,1090,1100,32,1077,1075,1086,32,1074,1088,1091,1095,1085,1091,1102,32,1080,1079,32,1092,1072,1081,1083,1072,58,32) -join "") + $css_code_file) -ForegroundColor Yellow
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host (([char[]](32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,1048,1053,1057,1058,1056,1059,1050,1062,1048,1071,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32) -join "")) -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host (([char[]](49,46,32,1054,1090,1082,1088,1086,1081,1090,1077,32,1085,1072,1089,1090,1088,1086,1081,1082,1080,32,77,105,108,108,101,110,110,105,117,109,32,1074,32,1082,1083,1080,1077,1085,1090,1077,32,83,116,101,97,109,46) -join ""))
Write-Host (([char[]](50,46,32,1055,1077,1088,1077,1081,1076,1080,1090,1077,32,1074,32,1088,1072,1079,1076,1077,1083,32,39,81,117,105,99,107,32,67,83,83,39,32,40,1054,1082,1085,1086,32,1074,1074,1086,1076,1072,32,1089,1090,1080,1083,1077,1081,41,46) -join ""))
Write-Host (([char[]](51,46,32,1055,1088,1086,1089,1090,1086,32,1085,1072,1078,1084,1080,1090,1077,32,67,116,114,108,43,86,44,32,1095,1090,1086,1073,1099,32,1074,1089,1090,1072,1074,1080,1090,1100,32,1075,1086,1090,1086,1074,1099,1077,32,1089,1090,1080,1083,1080,46) -join ""))
Write-Host (([char[]](52,46,32,1057,1086,1093,1088,1072,1085,1080,1090,1077,32,1080,32,1086,1073,1085,1086,1074,1080,1090,1077,32,1090,1077,1084,1091,32,1089,1082,1080,1085,1072,33) -join ""))
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host (([char[]](10,1042,1089,1077,32,1096,1072,1075,1080,32,1091,1089,1087,1077,1096,1085,1086,32,1074,1099,1087,1086,1083,1085,1077,1085,1099,33) -join "")) -ForegroundColor Green

Read-Host (([char[]](10,1053,1072,1078,1084,1080,1090,1077,32,69,110,116,101,114,32,1076,1083,1103,32,1074,1099,1093,1086,1076,1072,46,46,46) -join ""))
