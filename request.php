if (!$path) {
            //$path = Request::parsePathFromRequest('ORIG_PATH_INFO');
            $path = Request::parsePathFromRequest('REDIRECT_URL');
         }
