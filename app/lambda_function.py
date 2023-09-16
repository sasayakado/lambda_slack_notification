"""
This module is responsible for sending messages to Slack based on the current date and time.
"""

import sys
import traceback
import os
import slackweb
from date_utility import DateUtility

sys.path.append("/opt/")

SLACK_URL = os.environ["SLACK_URL"]
SLACK_USERID = os.environ["SLACK_USERID"]

def lambda_handler(_event, _context):
    """
    Lambda function handler to get the current date and time and send it to Slack.
    """
    try:
        current_time = DateUtility.get_current_time()
        today_str, today_time_str = DateUtility.format_time(current_time)

        msg = f'現在「{today_time_str}」です。 \nテストメッセージ'
        title = f"{today_str}テストタイトル"
        send_slack(title, f"{SLACK_USERID}\n{msg}")

    except Exception as exc:  # pylint: disable=broad-except
        print(f"Exception occurred: {exc}")
        print(traceback.format_exc())

def send_slack(slack_title, msg):
    """
    Send a message to Slack.
    
    Args:
        slack_title (str): The title for the Slack message.
        msg (str): The message to be sent.
    """
    try:
        print("★--Slackに送る　開始--★")
        slack = slackweb.Slack(url=SLACK_URL)

        attachments = [
            {
                "color": "#36a64f",
                "author_name": "test_author",
                "title": slack_title,
                "text": msg
            }
        ]
        slack.notify(text="", attachments=attachments)
        print("★--Slackに送る　終了--★")
    except Exception as exc:  # pylint: disable=broad-except
        print(f"Exception occurred: {exc}")
        print(traceback.format_exc())

if __name__ == "__main__":
    test_event = {}
    test_context = {}
    lambda_handler(test_event, test_context)
