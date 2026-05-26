function startPatch() {
	console.log('Injected into game view page!');

	Millennium.findElement(document, 'div#appHubAppName').then((elements) => {
		document.querySelector('#game_highlights .glance_ctn').appendChild(elements[0]);
	});

	Millennium.findElement(document, '.page_title_area.game_title_area.page_content .apphub_HomeHeaderContent').then((elements) => {
		document.querySelector('#game_highlights .glance_ctn').appendChild(elements[0]);
	});

	const currentAppId = window.location.pathname.split('/')[2];

	const observer = new MutationObserver(() => {
		const elements = document.querySelectorAll('.highlight_strip_item img');
		if (elements.length) {
			elements.forEach((element) => {
				element.src = element.src.replace(/\.\d+x\d+/, '');
			});
		}
	});

	observer.observe(document.body, { childList: true, subtree: true });

	Millennium.findElement(document, '.page_title_area.game_title_area.page_content').then((elements) => {
		if (document.querySelector('.game_area_play_stats') !== null) {
			document.querySelector('.rightcol.game_meta_data').style.marginRight = 'calc(100% - 1348px) !important;';
		}

		const gameName = document.querySelector('div#appHubAppName').textContent;
		const tags = document.querySelector('.glance_tags_ctn').innerHTML;
		const developerTags = document.querySelectorAll('.dev_row .summary.column');
		6;
		const developerTagsHtml = Array.from(developerTags).map((tag) => {
			return tag.innerHTML;
		});

		const reviewRecent = document.querySelectorAll('span.nonresponsive_hidden.responsive_reviewdesc')[0];
		const reviewAll = document.querySelectorAll('span.nonresponsive_hidden.responsive_reviewdesc')[1];

		console.log(reviewRecent?.textContent);
		console.log(reviewAll?.textContent);

		let recentReviewPercent = -1;
		let recentReviewerCount = -1;

		let allReviewPercent = -1;
		let allReviewerCount = -1;

		// -- Legacy review count code
		// const match = reviewRecent?.textContent.match(/(\d+)% of the ([\d,]+) user reviews/);

		// if (match) {
		// 	recentReviewPercent = parseInt(match[1], 10);
		// 	recentReviewerCount = parseInt(match[2].replace(/,/g, ''), 10);
		// } else {
		// 	console.log('No match found for recent reviews');
		// }

		// const matchAll = reviewAll?.textContent.match(/(\d+)% of the ([\d,]+) user reviews/);

		// if (matchAll) {
		// 	allReviewPercent = parseInt(matchAll[1], 10);
		// 	allReviewerCount = parseInt(matchAll[2].replace(/,/g, ''), 10);
		// } else {
		// 	console.log('No match found for all reviews');
		// }

		// Updated review count code to support multiple languages
		const recentSplitArr = reviewRecent?.textContent.split(' ');
		let thirtyCount = -1;

		const allSplitArr = reviewAll?.textContent.split(' ');
		if (allSplitArr) {
			for (let i = 0; i < allSplitArr.length; i++) {
				let cI = parseInt(allSplitArr[i].replace(/,/g, ''), 10);

				if (isNaN(cI)) {
					continue;
				} else {
					console.log(cI);
					allSplitArr[i].includes('%') ? (allReviewPercent = cI) : (allReviewerCount = cI);
				}
			}
		} else {
			console.log('No match found for all reviews');
		}

		if (recentSplitArr) {
			for (let i = 0; i < recentSplitArr.length; i++) {
				let cI = parseInt(recentSplitArr[i].replace(/,/g, ''), 10);

				if (isNaN(cI)) {
					continue;
				} else {
					if (recentSplitArr[i].includes('%')) {
						reviewAll ? (recentReviewPercent = cI) : (allReviewPercent = cI);
					} else {
						cI === 30 ? thirtyCount++ : reviewAll ? (recentReviewerCount = cI) : (allReviewerCount = cI);
						thirtyCount > 0 ? (recentReviewerCount = cI) : null;
					}
				}
			}
		} else {
			console.log('No match found for recent reviews');
		}

		const gameIcon = document.querySelector('.apphub_AppIcon img').outerHTML;
		const gameBanner = document.querySelector('img.game_header_image_full').src;
		const gameDescription = document.querySelector('.game_description_snippet')?.innerHTML ?? "";

		const html = `

    <style>
        .customImageBackground .image {
            background-image: 
                linear-gradient(to bottom right, rgba(0, 0, 0, 1), rgba(0, 0, 0, 0)),
                linear-gradient(to top, #393939, rgba(48, 48, 48, 0)),
                url('${gameBanner}');
        }

        .customGameTags {
            z-index: 1
        }

        .customGameTags>div.glance_tags {
            margin: 15px 0 10px 0px;
        }
    </style>

    <div class="glance_ctn">
        <div class="customImageBackground">
            <div class="image"></div>
        </div>
        <div class="apphubCustom_GameDetails">
            <div class="leftSideIcon">
                ${gameIcon}
            </div>
            <div class="rightSideDetails">
                <div class="customGameTitle">${gameName}</div>
                <div class="customGameDeveloperTags">${developerTagsHtml}</div>
                <div class="customGameTags reviews">
                   
                    ${
						recentReviewPercent >= 0 && recentReviewerCount >= 0
							? `
                        Recent Reviews:
                        <div class="reviewsPercent">${recentReviewPercent}%</div>
                        <div class="reviewsCount">(${recentReviewerCount} reviews)</div>
                        `
							: ''
					}

                    ${
						allReviewPercent >= 0 && allReviewerCount >= 0
							? `
                        All Reviews:
                        <div class="reviewsPercent">${allReviewPercent}%</div>
                        <div class="reviewsCount">(${allReviewerCount} reviews)</div>
                        `
							: ''
					}
                </div>
            </div>
        </div>  
        <div class="customGameTags">${tags}</div>
        <div class="customGameDescription">${gameDescription}</div>
    </div>
    `;
		elements[0].insertAdjacentHTML('beforeend', html);
	});

	Millennium.findElement(document, '.customGameTags.reviews').then(() => {
		document.querySelector('.customGameTags.reviews').addEventListener('click', () => {
			window.scrollTo({
				top: document.querySelector('.user_reviews_header').getBoundingClientRect().top - 30,
				behavior: 'smooth',
			});
		});
	});
}

function waitForBodyElement() {
	if (document.body && document.body.nodeType === Node.ELEMENT_NODE) {
		startPatch();
		return;
	}

	if (document.readyState === 'loading') {
		const onReady = () => {
			document.removeEventListener('DOMContentLoaded', onReady);
			if (document.body) startPatch();
		};
		document.addEventListener('DOMContentLoaded', onReady);
		return;
	}

	const poll = setInterval(() => {
		if (document.body) {
			clearInterval(poll);
			startPatch();
		}
	}, 50);
}

waitForBodyElement();
