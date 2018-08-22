import requests, datetime, time, os, csv, sys

class AzureEABillingCollector(object):
  """
  Class to export Azure billing and usage information extracted via ea.azure.com
  """

  def __init__(self, enrollment, token, timeout):
    """
    Constructor.
    
    :param enrollment: ID of the enterprise agreement (EA)
    :param token: Access Key generated via the EA portal
    :param timeout: Timeout to use for the request against the EA portal
    """

    self._enrollment = enrollment
    self._token = token
    self._timeout = timeout

  def get_usage_details(self, start_date, end_date):
    """
    Request the billing data from the Azure API and return a dict with the data
    :param start_date: string for the given day 
    :param end_date: string for the given day
    :return: JSON document of Azure usage and billing information
    """
        
    headers = {"Authorization": "Bearer {}".format(self._token)}
    url = "https://consumption.azure.com/v2/enrollments/{0}/usagedetails/download?startTime={1}&endTime={2}".format(self._enrollment, start_date, end_date)
    rsp = requests.get(url, headers=headers, timeout=self._timeout)
    rsp.raise_for_status()

    if rsp.text.startswith('"Usage Data Extract"'):
      # TODO: check no usage details edge case
      # special treatement for no usage details. Azure API doesn't return a JSON document in that case...
      return dict()

    return rsp

  def write_usage_telegraf(self, csv_list, start_date, end_date):
    """
    Write each row in the Azure billing data csv file to InfluxDB as a data point
    :param csv_list: list of csv billing data where each list corresponds to one row
    :param start_date: string for start date of the billing data
    :param end_date: string for the end date of the billing data
    """

    # Calculate Unix timestamp in nanoseconds for end_date 
    dt = datetime.datetime(year=int(end_date[:4]), month=int(end_date[5:7]), day=int(end_date[8:]))
    epoch = datetime.datetime.utcfromtimestamp(0)
    time_str = (dt - epoch).total_seconds() * 1e+9

    # Add the start_date and end_date for billing period as tags
    payload_str = "azure_billing, start_date=" + start_date + ",end_date=" + end_date
    keys = csv_list[0]

    # For every line in the csv file, create a data point in influxDB
    for li in csv_list[1:]:
      for i,key in enumerate(keys):
        value = li[i]
        # Escape commas, quotes and spaces in the tag values
        value = value.replace(' ','\ ').replace('"','\\"').replace(',','\,')
        if key=="Cost":
          field_str = "cost=" + value
        payload_str += "," + key + "=" + value
      payload_str += " " + field_str + " " + str(time_str)

      # TELEGRAF_HTTP_SERVICE_HOST is an environment variable
      # TODO: Check with a real database
      headers = {'Content-Type': 'application/octet-stream'}
      url = "http://" + os.environ['TELEGRAF_HTTP_SERVICE_HOST'] + ":8186/write"
      rsp = requests.post(url, headers=headers, data=payload_str, timeout=self._timeout)
      rsp.raise_for_status()

def main(argv):
  # If no start_date and end_date then use yesterdays date
  if len(argv) < 1:
    print("No dates provided, using yesterdays date... \nUsage: azure_billing_api.py <start_date> [<end_date>]\n")
    yesterday = datetime.datetime.today() - datetime.timedelta(days=1)
    start_date = yesterday.strftime("%Y-%m-%d")
    end_date=start_date
  elif (len(argv) == 1):
    start_date = end_date = argv[0]
  else: 
    start_date = argv[0]
    end_date = argv[1]
  
  print("Start date=" + start_date + ", End date=" + end_date)
  print("Connecting to the Billing API...")
  # ENROLLMENT_NUM and API_KEY are environment variables
  billing_obj = AzureEABillingCollector(int(os.environ['ENROLLMENT_NUM']), os.environ['ENROLLMENT_NUM'], 30)
  print("Getting the usage details..")
  rsp = billing_obj.get_usage_details()
  csv_content = rsp.content.decode('utf-8')
  print("Finished getting usage details..\n")

  print("Beginning upload to Telegraf..")
  billing_obj.write_usage_telegraf(csv_list, start_date, end_date)
  print("Finished upload to Telegraf..")

if __name__ == "__main__":
  main(sys.argv[1:])