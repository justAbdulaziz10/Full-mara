import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  vus: 50,
  duration: '2m',
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% < 500ms
    http_req_failed: ['rate<0.01']
  }
};

export default function () {
  const res = http.get('http://localhost:8000/healthz');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
