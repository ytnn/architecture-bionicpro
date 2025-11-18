import React, { useState } from 'react';
import { useKeycloak } from '@react-keycloak/web';

const ReportPage: React.FC = () => {
  const { keycloak, initialized } = useKeycloak();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [report, setReport] = useState<any>(null);

  const downloadReport = async () => {
    if (!keycloak?.token) {
      setError('Not authenticated');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      setReport(null);

      const current_user = await fetch(`${process.env.REACT_APP_API_URL}/users/current`, {
        headers: { Authorization: `Bearer ${keycloak.token}` },
      });

      if (!current_user.ok) {
        const body = await current_user.json().catch(() => ({}));
        throw new Error(body.detail || 'Cannot get user profile');
      }

      const current_user_obj = await current_user.json();
      const clientId = current_user_obj.client_id;

      const res = await fetch(`${process.env.REACT_APP_API_URL}/reports?client_id=${clientId}`, {
        headers: { Authorization: `Bearer ${keycloak.token}` },
      });

      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.detail || 'Error loading report');
      }

      const data = await res.json();
      setReport(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  if (!initialized) {
    return <div>Loading...</div>;
  }

  if (!keycloak.authenticated) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
        <button
          onClick={() => keycloak.login()}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
          Login
        </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
      <div className="p-8 bg-white rounded-lg shadow-md">
        <h1 className="text-2xl font-bold mb-6">Usage Reports</h1>
        
        <button
          onClick={downloadReport}
          disabled={loading}
          className={`px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 ${
            loading ? 'opacity-50 cursor-not-allowed' : ''
          }`}
        >
          {loading ? 'Generating Report...' : 'Download Report'}
        </button>

        {error && (
          <div className="mt-4 p-4 bg-red-100 text-red-700 rounded">
            {error}
          </div>
        )}

        {report && (
          <div className="mt-6">
            <h2 className="text-lg font-semibold mb-2">Данные отчёта</h2>
            <div className="overflow-x-auto">
              <table className="min-w-full text-sm border border-gray-200">
                <tbody>
                  <tr className="bg-gray-50">
                    <td className="border px-3 py-2 font-semibold w-1/3">ID клиента</td>
                    <td className="border px-3 py-2">{report.client_id}</td>
                  </tr>
                  <tr>
                    <td className="border px-3 py-2 font-semibold">ФИО</td>
                    <td className="border px-3 py-2">{report.full_name}</td>
                  </tr>
                  <tr className="bg-gray-50">
                    <td className="border px-3 py-2 font-semibold">Email</td>
                    <td className="border px-3 py-2">{report.email}</td>
                  </tr>
                  <tr>
                    <td className="border px-3 py-2 font-semibold">Страна</td>
                    <td className="border px-3 py-2">{report.country}</td>
                  </tr>
                  <tr className="bg-gray-50">
                    <td className="border px-3 py-2 font-semibold">Тип протеза</td>
                    <td className="border px-3 py-2">{report.prosthesis_type}</td>
                  </tr>
                  <tr>
                    <td className="border px-3 py-2 font-semibold">Активных дней</td>
                    <td className="border px-3 py-2">{report.days_active}</td>
                  </tr>
                  <tr className="bg-gray-50">
                    <td className="border px-3 py-2 font-semibold">Событий всего</td>
                    <td className="border px-3 py-2">{report.total_events}</td>
                  </tr>
                  <tr>
                    <td className="border px-3 py-2 font-semibold">Средний сигнал</td>
                    <td className="border px-3 py-2">{report.avg_signal}</td>
                  </tr>
                  <tr className="bg-gray-50">
                    <td className="border px-3 py-2 font-semibold">Макс. сигнал</td>
                    <td className="border px-3 py-2">{report.max_signal}</td>
                  </tr>
                  <tr>
                    <td className="border px-3 py-2 font-semibold">Мин. сигнал</td>
                    <td className="border px-3 py-2">{report.min_signal}</td>
                  </tr>
                  <tr className="bg-gray-50">
                    <td className="border px-3 py-2 font-semibold">Первое событие</td>
                    <td className="border px-3 py-2">
                      {new Date(report.first_event_at).toLocaleString()}
                    </td>
                  </tr>
                  <tr>
                    <td className="border px-3 py-2 font-semibold">Последнее событие</td>
                    <td className="border px-3 py-2">
                      {new Date(report.last_event_at).toLocaleString()}
                    </td>
                  </tr>
                  <tr className="bg-gray-50">
                    <td className="border px-3 py-2 font-semibold">Отчёт сформирован</td>
                    <td className="border px-3 py-2">
                      {new Date(report.generated_at).toLocaleString()}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ReportPage;
