<?php

 /*
 *
 * @file plugins/generic/seriesIndexPage/SeriesIndexPagePlugin.inc.php
 *
 * Copyright (c) 2021 Language Science Press
 * Developed by Ronald Steffen
 * Distributed under the GNU GPL v3. For full terms see the file docs/LICENSE.
 *
 * @brief SeriesIndexPagePlugin class definition
 *
 */


import('lib.pkp.classes.plugins.GenericPlugin');

class SeriesIndexPagePlugin extends GenericPlugin
{
    public function register($category, $path, $mainContextId = null)
    {

	$success = parent::register($category, $path, $mainContextId);
        // If the system isn't installed, or is performing an upgrade, don't
        // register hooks. This will prevent DB access attempts before the
        // schema is installed.
        if (!Config::getVar('general', 'installed') || defined('RUNNING_UPGRADE')) {
            return true;
        }
        
        if ($success) {
            if ($this->getEnabled($mainContextId)) {
                if ($this->getEnabled()) {
                    $this->addLocaleData();

                    // register locale files for reviews grid controller classes
                    $locale = AppLocale::getLocale();
                    AppLocale::registerLocaleFile($locale, 'plugins/generic/seriesIndexPage/locale/'.$locale.'/locale.po');

                    // register hooks
                    HookRegistry::register('LoadHandler', array($this, 'loadSeriesIndexPageHandler'));
                    HookRegistry::register('TemplateResource::getFilename', array($this, 'getTemplateFilePath'));
                }
            }
            return $success;
        }
        return $success;
    }

    function loadSeriesIndexPageHandler($hookname, $params) {
        $page = $params[0];
        $op = &$params[1];
        $sourceFile = &$params[2];

        switch ($page) {
            case 'seriesIndex':
                switch ($op) {
                    case 'index':
                        define('HANDLER_CLASS', 'SeriesIndexPageHandler');
                        $this->import('SeriesIndexPageHandler');
                        break;
                }
                return true;
            }
        return false;
    }

	function getDisplayName() {
		return __('plugins.generic.seriesIndexPage.displayName');
	}

	function getDescription() {
		return __('plugins.generic.seriesIndexPage.description');
	}

    function getTemplateFilePath($hookname, $args)
    {
        switch ($args[1]) {
        case 'seriesIndex.tpl':
            $args[0] = 'plugins/generic/seriesIndexPage/templates/seriesIndex.tpl';
            return false;
        }
    }
}
?>
