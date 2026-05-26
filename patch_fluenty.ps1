# Set console output and input to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "                    LuaTools для Millenium                " -ForegroundColor Cyan
Write-Host "      Автор: Le Maxime (t.me/lemaxime)                    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$steam_skin_path = "C:\Program Files (x86)\Steam\steamui\skins\fluenty"
$local_workspace_path = "g:\work\fluenty"
$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($script_dir)) {
    $script_dir = $PSScriptRoot
}
if ([string]::IsNullOrEmpty($script_dir)) {
    $script_dir = Get-Location
}
$sibling_path = Join-Path $script_dir "fluenty"

$theme_dir = $null

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

$css_code_file = Join-Path $script_dir "quick-css-code.css"

if ($null -eq $theme_dir) {
    Write-Host "ОШИБКА: Директория темы Fluenty не найдена!" -ForegroundColor Red
    Write-Host "Убедитесь, что тема установлена по одному из путей:"
    Write-Host "  - $steam_skin_path"
    Write-Host "  - или папка 'fluenty' находится рядом с этим патчером."
    Read-Host "`nНажмите Enter для выхода..."
    Exit 1
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin -and $theme_dir.StartsWith("C:\Program Files", [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Host "Для модификации файлов темы в Program Files требуются права администратора." -ForegroundColor Yellow
    Write-Host "Перезапуск от имени администратора..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "Активная папка темы обнаружена:`n$theme_dir`n" -ForegroundColor Green

# -------------------------------------------------------------------------
# ШАГ 1: ДИНАМИЧЕСКИЕ ИНЪЕКЦИИ JS
# -------------------------------------------------------------------------
Write-Host "[ШАГ 1] Выполнение динамических JS-инъекций..."
Start-Sleep -Milliseconds 300

$sidebar_path = Join-Path $theme_dir "src\scripts\components\sidebar.js"
$sidebar_success = $false

if (Test-Path $sidebar_path) {
    try {
        $content = [System.IO.File]::ReadAllText($sidebar_path, [System.Text.Encoding]::UTF8)

        $translations = @{
            'title="Go back"' = 'title="Назад"'
            'title="Store"' = 'title="Магазин"'
            'text">Store</div>' = 'text">Магазин</div>'
            'title="Library"' = 'title="Библиотека"'
            'text">Library</div>' = 'text">Библиотека</div>'
            'title="Collections"' = 'title="Коллекции"'
            'text">Collections</div>' = 'text">Коллекции</div>'
            'title="Community"' = 'title="Сообщество"'
            'text">Community</div>' = 'text">Сообщество</div>'
            'title="Market"' = 'title="Торговая площадка"'
            'text">Market</div>' = 'text">Торговая площадка</div>'
            'title="Activity"' = 'title="Активность"'
            'text">Activity</div>' = 'text">Активность</div>'
            'title="Downloads"' = 'title="Загрузки"'
            'text">Downloads</div>' = 'text">Загрузки</div>'
            'title="Friends"' = 'title="Друзья"'
            'text">Friends</div>' = 'text">Друзья</div>'
            'title="Settings"' = 'title="Настройки"'
            'text">Settings</div>' = 'text">Настройки</div>'
        }

        foreach ($eng in $translations.Keys) {
            $content = $content.Replace($eng, $translations[$eng])
        }

        # Inject LuaTools sidebar HTML if missing
        if ($content -notlike '*id="luatools-sidebar-btn"*') {
            $old_section_pattern = '(?s)<div title="Настройки" class="button" id="settings">\s*<div class="icon"></div>\s*<div class="text">Настройки</div>\s*</div>'
            $new_section = @'
<div title="Настройки" class="button" id="settings">
				<div class="icon"></div>
				<div class="text">Настройки</div>
			</div>
			<div title="LuaTools" class="button" id="luatools-sidebar-btn" style="display: none;">
				<div class="icon"></div>
				<div class="text">LuaTools</div>
			</div>
'@
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
        Write-Host "  [+] Файл sidebar.js успешно переведен и пропатчен!" -ForegroundColor Green
        $sidebar_success = $true
    } catch {
        Write-Host "  [-] Не удалось пропатчить sidebar.js: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  [-] Файл sidebar.js не найден по пути: $sidebar_path" -ForegroundColor Yellow
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
        Write-Host "  [+] Файл viewGame.js успешно пропатчен!" -ForegroundColor Green
        $viewgame_success = $true
    } catch {
        Write-Host "  [-] Не удалось пропатчить viewGame.js: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  [-] Файл viewGame.js не найден по пути: $viewgame_path" -ForegroundColor Yellow
}

if ($sidebar_success -and $viewgame_success) {
    Write-Host "`n[УСПЕХ] ШАГ 1 ЗАВЕРШЕН! JS-файлы успешно переведены и модифицированы.`n" -ForegroundColor Green
} else {
    Write-Host "`n[ВНИМАНИЕ] ШАГ 1 ЗАВЕРШЕН С ОШИБКАМИ. Проверьте сообщения выше.`n" -ForegroundColor Yellow
}

# -------------------------------------------------------------------------
# ШАГ 2: СОЗДАНИЕ QUICK CSS И КОПИРОВАНИЕ В БУФЕР ОБМЕНА
# -------------------------------------------------------------------------
Write-Host "[ШАГ 2] Подготовка стилей Quick CSS..."
Start-Sleep -Milliseconds 300

$css_content = @'
/* --- Иконка LuaTools в боковом меню --- */
.section #luatools-sidebar-btn.button .icon::before {
	content: '' !important;
}
.section #luatools-sidebar-btn.button:active .icon::before {
	content: '' !important;
}

/* --- Оформление плашек (Denuvo / Online-Fix) и кнопок заголовка --- */
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
    Write-Host "  [+] Стили Quick CSS сохранены в файл: $css_code_file" -ForegroundColor Green
} catch {
    Write-Host "  [-] Не удалось записать CSS-файл: $_" -ForegroundColor Red
}

try {
    Set-Clipboard -Value $css_content -ErrorAction Stop
    Write-Host "  [+] Код стилей АВТОМАТИЧЕСКИ скопирован в буфер обмена Windows!" -ForegroundColor Green
} catch {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::SetText($css_content)
        Write-Host "  [+] Код стилей АВТОМАТИЧЕСКИ скопирован в буфер обмена Windows!" -ForegroundColor Green
    } catch {
        Write-Host "  [-] Не удалось скопировать код автоматически. Вы можете скопировать его вручную из файла: $css_code_file" -ForegroundColor Yellow
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "                     ИНСТРУКЦИЯ                           " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "1. Откройте настройки Millennium в клиенте Steam."
Write-Host "2. Перейдите в раздел 'Quick CSS' (Окно ввода стилей)."
Write-Host "3. Просто нажмите Ctrl+V, чтобы вставить готовые стили."
Write-Host "4. Сохраните и обновите тему скина!"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "`nВсе шаги успешно выполнены!" -ForegroundColor Green

Read-Host "`nНажмите Enter для выхода..."
