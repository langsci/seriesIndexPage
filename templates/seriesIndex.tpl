{**
 * templates/seriesIndex.tpl adopted from templates/frontend/pages/catalogSeries.tpl
 *
 * Copyright (c) 2014-2020 Simon Fraser University
 * Copyright (c) 2003-2020 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Display the page to view books in a series in the catalog.
 *
 * @uses $series Series Current series being viewed
 * @uses $publishedSubmissions array List of published submissions in this series
 * @uses $featuredMonographIds array List of featured monograph IDs in this series
 * @uses $newReleasesMonographs array List of new monographs in this series
 * @uses $prevPage int The previous page number
 * @uses $nextPage int The next page number
 * @uses $showingStart int The number of the first item on this page
 * @uses $showingEnd int The number of the last item on this page
 * @uses $total int Count of all published submissions in this series
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated="{translate key="plugins.generic.seriesIndexPage.title"}"|escape}

<link rel="stylesheet" href="{$baseurl}/plugins/generic/seriesIndexPage/css/main.css" type="text/css" />

<div class="page page_catalog_series">

	{* Breadcrumb *}
	{include file="frontend/components/breadcrumbs_catalog.tpl" type="series" currentTitle="{translate key="plugins.generic.seriesIndexPage.title"}"}
	<h1>{translate key="plugins.generic.seriesIndexPage.title"|escape}</h1>
		
	{* Count of series in this press *}
	<div class="monograph_count">
		{translate key="plugins.generic.seriesIndexPage.browseSeries" numSeries=$total}
	</div>

	{* No published series *}
	{if empty($data)}
		<p>{translate key="plugins.generic.seriesIndexPage.noSeries"}</p>
	{else}
	
		<div class="cmp_monographs_list">
			{foreach from=$data item=item name=series_loop}
				<div class="series_overview_row">
					<div class=series_overview_series_title>
						<a href="{url page="catalog" op="series" path={$item['series']->getPath()|escape}}">{$item['series']->getLocalizedTitle()|escape}</a>
					</div>
					<div class=series_overview_text>
						{if $item['submissions']|count-$item['countForthcoming'] > 1}
							{assign var=pluralSuffix value='s'}
						{else}
							{assign var=pluralSuffix value=''}
						{/if}
						{if $item['countForthcoming'] > 0}
							{translate key="plugins.generic.seriesIndexPage.seriesLabelBooksForthcoming"|escape suffix=$pluralSuffix nBooks=$item['submissions']|count-$item['countForthcoming'] nForthcoming=$item['conutForthcoming']}
						{else}
							{translate key="plugins.generic.seriesIndexPage.seriesLabelBooks"|escape suffix=$pluralSuffix nBooks=$item['submissions']|count}
						{/if}
					</div>
				</div>
				<div id="series_overview_icon_row" class="series_overview_icon_row">
					<script>
						function scaleImg(img,flag) {
							if (window.matchMedia("(hover)").matches) {
								if (flag) {
									var scaledImg = document.createElement("img");
									scaledImg.id = "scaled";
									scaledImg.src = img.src;
									scaledImg.className = "series_overview_icon series_overview_icon_scaled";
									scaledImg.alt = "scaled image";

									var id = $('body').find('#' + img.parentElement.id);
									$(scaledImg).insertAfter(id);
								} else {
									$('#scaled').remove();
								}
							}
						}
					</script>	
					{foreach from=$item['submissions'] item=submission name=submissions_loop}
						{assign var=icon_id value="{$smarty.foreach.series_loop.iteration}-{$smarty.foreach.submissions_loop.iteration}"}
						{assign var="coverImage" value=$submission->getLocalizedData('coverImage')}
						<a id="{$icon_id}" href="{url page="catalog" op="book" path={$submission->getId()}}">
							<img class=series_overview_icon loading="lazy" src={$submission->getCurrentPublication()->getLocalizedCoverImageUrl($contextId)} alt="{$coverImage.altText|escape|default:'No alt text provided for this book cover.'}" onmouseover="scaleImg(this,true)" onmouseout="scaleImg(this,false)" ></a>
					{/foreach}
				</div>
			{/foreach}
		</div>

		{* Pagination *}
		{if $prevPage > 1}
			{capture assign=prevUrl}{url router=$smarty.const.ROUTE_PAGE page="seriesIndex" op="index" path=$prevPage}{/capture}
		{elseif $prevPage === 1}
			{capture assign=prevUrl}{url router=$smarty.const.ROUTE_PAGE page="seriesIndex" op="index" path="0"}{/capture}
		{/if}
		{if $nextPage}
			{capture assign=nextUrl}{url router=$smarty.const.ROUTE_PAGE page="seriesIndex" op="index" path=$nextPage}{/capture}
		{/if}
		{include
			file="frontend/components/pagination.tpl"
			prevUrl=$prevUrl
			nextUrl=$nextUrl
			showingStart=$showingStart
			showingEnd=$showingEnd
			total=$total
		}
	{/if}

</div><!-- .page -->

{include file="frontend/components/footer.tpl"}
