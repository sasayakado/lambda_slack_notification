"""
This module provides utilities for date and time operations,
specifically tailored for Japanese time zones.
"""

import datetime
import pytz

class DateUtility:
    """
    A utility class for handling date and time operations with a focus on Japanese time zones.
    """

    @staticmethod
    def get_current_time():
        """日本のタイムゾーンでの現在時刻を取得

        Returns:
        datetime: 現在の日本のタイムゾーンの日時。
        """
        tokyo_tz = pytz.timezone('Asia/Tokyo')
        return datetime.datetime.now(tokyo_tz)

    @staticmethod
    def format_time(current_time):
        """日時をフォーマットする

        Parameters:
        - current_time (datetime): フォーマットする日時。

        Returns:
        tuple: (日付の文字列, 日時の文字列)。
        """
        return current_time.strftime('%-m月%-d日'), current_time.strftime('%Y%m%d_%H:%M:%S')
