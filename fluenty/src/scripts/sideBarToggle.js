import { waitForElement } from './waitForElement.js';

export async function sideBarToggle() {
	let gameLib = await waitForElement('._2tC_c87MH67xQM7Y0pVyXm');
	let profileBar, storeBar;
	let defaultOpacity;
	let state = 'store';

	if (gameLib) {
		profileBar = document.querySelector('._2D64jIEK7wpUR_NlObDW76');
		storeBar = document.querySelectorAll('._2Lu3d-5qLmW4i19ysTt2jT._2UyOBeiSdBayaFdRa39N2O');

		defaultOpacity = window.getComputedStyle(storeBar[1]).opacity;
		profileBar.style.opacity = defaultOpacity;

		storeBar[0].after(profileBar);

		async function changeStateHandler() {
			storeBar[0].removeEventListener('contextmenu', changeStateHandler);
			await changeState(state).then(() => {
				setTimeout(() => {
					storeBar[0].addEventListener('contextmenu', changeStateHandler);
				}, 500);
			});
		}

		storeBar[0].addEventListener('contextmenu', changeStateHandler);
	}

	async function changeState(s) {
		if (s === 'store') {
			state = 'profile';
			for (let i = 1; i < storeBar.length; i++) {
				storeBar[i].style.visibility = 'hidden';
			}
			setTimeout(() => {
				profileBar.style.visibility = 'visible';
			}, 500);
		} else {
			state = 'store';
			profileBar.style.visibility = 'hidden';
			setTimeout(() => {
				for (let i = 1; i < storeBar.length; i++) {
					storeBar[i].style.visibility = 'visible';
				}
			}, 500);
		}
	}
}
