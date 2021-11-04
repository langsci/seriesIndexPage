<?php

 /*
 *
 * @file plugins/generic/seriesIndexPage/seriesIndexPageHandler.inc.php
 *
 * Copyright (c) 2021 Language Science Press
 * Developed by Ronald Steffen
 * Distributed under the GNU GPL v3. For full terms see the file docs/LICENSE.
 *
 * @brief seriesIndexPageHandler class definition
 *
 */

import('lib.pkp.pages.catalog.PKPCatalogHandler');

class seriesIndexPageHandler extends PKPCatalogHandler
{

    /**
     * Show the series index page
     * @param $args array 
     * @param $request PKPRequest
     */
    public function index($args, $request)
    {
		$page = isset($args[0]) ? (int) $args[0] : 1;
		$templateMgr = TemplateManager::getManager($request);
		$context = $request->getContext();

		// Get the series
		$seriesDao = DAORegistry::getDAO('SeriesDAO'); /* @var $seriesDao SeriesDAO */
		$allSeries = $seriesDao->getByPressId($context->getId());

		if (!$allSeries) {
			$request->redirect(null, 'catalog');
		};

		$count = $context->getData('itemsPerPage') ? $context->getData('itemsPerPage') : Config::getVar('interface', 'items_per_page');
		$offset = $page > 1 ? ($page - 1) * $count : 0;

		$data = array();

		// get monographs for each series
        while ($series = $allSeries->next()) {

			$orderOption = $series->getSortOption() ? $series->getSortOption() : ORDERBY_DATE_PUBLISHED . '-' . SORT_DIRECTION_DESC;
			list($orderBy, $orderDir) = explode('-', $orderOption);

            $params = array(
				'contextId' => $context->getId(),
				'seriesIds' => $series->getId(),
				'orderByFeatured' => true,
				'orderBy' => $orderBy,
				'orderDirection' => $orderDir == SORT_DIRECTION_ASC ? 'ASC' : 'DESC',
				'status' => STATUS_PUBLISHED,
			);
            $submissionsIterator = Services::get('submission')->getMany($params);

			$data[$series->getLocalizedTitle()] = [
				'series' => $series,
				'submissions' => iterator_to_array($submissionsIterator)
			];
        }

		$this->setupTemplate($request);

		$total = count($data);

		$this->_setupPaginationTemplate($request, count($data), $page, $count, $offset, $total);

		ksort($data);
		$data = array_slice($data, $offset, $count);

		$templateMgr->assign(array(
			'contextId' => $context->getId(),
			'data' => $data,
			'baseurl' => $request->getBaseUrl()
		));

        $templateMgr->display('seriesIndex.tpl');
    }
}
?>