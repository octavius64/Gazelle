<?
if (!extension_loaded('date')) {
	error('Date extension not loaded.');
}

function time_ago($TimeStamp) {
	if (!is_number($TimeStamp)) { // Assume that $TimeStamp is SQL timestamp
		if ($TimeStamp == '0000-00-00 00:00:00') {
			return false;
		}
		$TimeStamp = strtotime($TimeStamp);
	}
	if ($TimeStamp == 0) {
		return false;
	}
	return time() - $TimeStamp;
}

/*
 * Returns a <span> by default but can optionally return the raw time
 * difference in text (e.g. "16 hours and 28 minutes", "1 day, 18 hours").
 */
function time_diff($TimeStamp, $Levels = 2, $Span = true, $Lowercase = false, $StartTime = false) {
	$StartTime = ($StartTime === false) ? time() : strtotime($StartTime);

	if (!is_number($TimeStamp)) { // Assume that $TimeStamp is SQL timestamp
		if ($TimeStamp == '0000-00-00 00:00:00') {
			return 'Never';
		}
		$TimeStamp = strtotime($TimeStamp);
	}
	if ($TimeStamp == 0) {
		return 'Never';
	}
	$Time = $StartTime - $TimeStamp;

	// If the time is negative, then it expires in the future.
	if ($Time < 0) {
		$Time = -$Time;
		$HideAgo = true;
	}

	$Years = floor($Time / 31556926); // seconds in one year
	$Remain = $Time - $Years * 31556926;

	$Months = floor($Remain / 2629744); // seconds in one month
	$Remain = $Remain - $Months * 2629744;

	$Weeks = floor($Remain / 604800); // seconds in one week
	$Remain = $Remain - $Weeks * 604800;

	$Days = floor($Remain / 86400); // seconds in one day
	$Remain = $Remain - $Days * 86400;

	$Hours=floor($Remain / 3600); // seconds in one hour
	$Remain = $Remain - $Hours * 3600;

	$Minutes = floor($Remain / 60); // seconds in one minute
	$Remain = $Remain - $Minutes * 60;

	$Seconds = $Remain;

	$Return = '';

	if ($Years > 0 && $Levels > 0) {
		if ($Years > 1) {
			$Return .= "$Years years";
		} else {
			$Return .= "$Years year";
		}
		$Levels--;
	}

	if ($Months > 0 && $Levels > 0) {
		if ($Return != '') {
			$Return .= ', ';
		}
		if ($Months > 1) {
			$Return .= "$Months months";
		} else {
			$Return .= "$Months month";
		}
		$Levels--;
	}

	if ($Weeks > 0 && $Levels > 0) {
		if ($Return != '') {
			$Return .= ', ';
		}
		if ($Weeks > 1) {
			$Return .= "$Weeks weeks";
		} else {
			$Return .= "$Weeks week";
		}
		$Levels--;
	}

	if ($Days > 0 && $Levels > 0) {
		if ($Return != '') {
			$Return .= ', ';
		}
		if ($Days > 1) {
			$Return .= "$Days days";
		} else {
			$Return .= "$Days day";
		}
		$Levels--;
	}

	if ($Hours > 0 && $Levels > 0) {
		if ($Return != '') {
			$Return .= ', ';
		}
		if ($Hours > 1) {
			$Return .= "$Hours hours";
		} else {
			$Return .= "$Hours hour";
		}
		$Levels--;
	}

	if ($Minutes > 0 && $Levels > 0) {
		if ($Return != '') {
			$Return .= ' and ';
		}
		if ($Minutes > 1) {
			$Return .= "$Minutes mins";
		} else {
			$Return .= "$Minutes min";
		}
		$Levels--;
	}

	if ($Return == '') {
		$Return = 'Just now';
	} elseif (!isset($HideAgo)) {
		$Return .= ' ago';
	}

	if ($Lowercase) {
		$Return = strtolower($Return);
	}

	if ($Span) {
		return '<span class="time tooltip" title="'.date('M d Y, H:i', $TimeStamp).'">'.$Return.'</span>';
	} else {
		return $Return;
	}
}

/* SQL utility functions */

function time_plus($Offset) {
	return date('Y-m-d H:i:s', time() + $Offset);
}

function time_minus($Offset, $Fuzzy = false) {
	if ($Fuzzy) {
		return date('Y-m-d 00:00:00', time() - $Offset);
	} else {
		return date('Y-m-d H:i:s', time() - $Offset);
	}
}

function sqltime($timestamp = false) {
	if ($timestamp === false) {
		$timestamp = time();
	}
	return date('Y-m-d H:i:s', $timestamp);
}

function validDate($DateString) {
	$DateTime = explode(' ', $DateString);
	if (legacy_count($DateTime) != 2) {
		return false;
	}
	list($Date, $Time) = $DateTime;
	$SplitTime = explode(':', $Time);
	if (legacy_count($SplitTime) != 3) {
		return false;
	}
	list($H, $M, $S) = $SplitTime;
	if ($H != 0 && !(is_number($H) && $H < 24 && $H >= 0)) { return false; }
	if ($M != 0 && !(is_number($M) && $M < 60 && $M >= 0)) { return false; }
	if ($S != 0 && !(is_number($S) && $S < 60 && $S >= 0)) { return false; }
	$SplitDate = explode('-', $Date);
	if (legacy_count($SplitDate) != 3) {
		return false;
	}
	list($Y, $M, $D) = $SplitDate;
	return checkDate($M, $D, $Y);
}

function is_valid_date($Date) {
	return is_valid_datetime($Date, 'Y-m-d');
}

function is_valid_time($Time) {
	return is_valid_datetime($Time, 'H:i');
}

function is_valid_datetime($DateTime, $Format = 'Y-m-d H:i') {
	$FormattedDateTime = DateTime::createFromFormat($Format, $DateTime);
	return $FormattedDateTime && $FormattedDateTime->format($Format) == $DateTime;
}

?>
