from locust import HttpUser,TaskSet, task, between, tag

import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

from skywalking import agent, config

config.init(agent_collector_backend_services='oap:11800', agent_name='local_locust', agent_instance_name='locust_test')

agent.start()

class MyTaskSet(TaskSet):
    @task
    @tag("Critical")
    def rachel(self):
        self._make_request("/")
        self._make_request("/select/vmui/?#/")
        self._make_request("/select/vmui/?#/?query=*&g0.range_input=5m&g0.end_input=2024-09-10T11%3A20%3A33&g0.relative_time=last_5_minutes&limit=5")
        self._make_request("/metrics")
        self._make_request("/flags")

    def _make_request(self, url, verify_path="/etc/ssl/certs/local.org.crt"):
        try:
            logging.info(f"Response start>>> URL: {url}")
            response = self.client.get(url, verify=verify_path)
        except Exception as e:
            logging.error("An error occurred: %s", e)
        else:
            logging.info(f"Response status code: [{response.status_code}]")
            return response
        finally:
            logging.info(f"Response Critical end <<<<<<{response.url}")


class MyUser(HttpUser):
    tasks = [MyTaskSet]
    wait_time = between(5, 15)
    logging.info(f"time: {wait_time}")
    host = "https://vmlogs.local.org"  # 这里设置你的域名
