import React from 'react';
import { Database, Server, Cloud, GitBranch, Package, Shield, Bell, BarChart3, Globe, Lock } from 'lucide-react';

export default function DevOpsArchitecture() {
  return (
    <div className="w-full h-full bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 p-8 overflow-auto">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold text-white mb-2 text-center">
          Microservices DevOps Infrastructure
        </h1>
        <p className="text-blue-200 text-center mb-8">AWS Cloud with Terraform, Docker & CI/CD</p>

        <div className="space-y-8">
          {/* CI/CD Layer */}
          <div className="bg-purple-900/30 border-2 border-purple-500 rounded-lg p-6">
            <div className="flex items-center gap-2 mb-4">
              <GitBranch className="text-purple-400" size={24} />
              <h2 className="text-xl font-bold text-purple-300">CI/CD Pipeline (GitHub Actions)</h2>
            </div>
            <div className="grid grid-cols-5 gap-4">
              {['Code Push', 'Build & Test', 'Docker Build', 'Security Scan', 'Deploy'].map((step, i) => (
                <div key={i} className="bg-purple-800/50 p-3 rounded text-center">
                  <div className="text-white font-semibold text-sm">{step}</div>
                </div>
              ))}
            </div>
          </div>

          {/* AWS Cloud */}
          <div className="bg-orange-900/20 border-2 border-orange-500 rounded-lg p-6">
            <div className="flex items-center gap-2 mb-6">
              <Cloud className="text-orange-400" size={24} />
              <h2 className="text-xl font-bold text-orange-300">AWS Cloud Infrastructure</h2>
            </div>

            {/* VPC */}
            <div className="bg-blue-900/30 border border-blue-400 rounded-lg p-6 mb-4">
              <h3 className="text-lg font-semibold text-blue-300 mb-4">VPC (Virtual Private Cloud)</h3>

              <div className="grid grid-cols-2 gap-6">
                {/* Public Subnet */}
                <div className="bg-green-900/30 border border-green-500 rounded-lg p-4">
                  <h4 className="text-green-300 font-semibold mb-3 flex items-center gap-2">
                    <Globe size={18} />
                    Public Subnet
                  </h4>
                  <div className="space-y-3">
                    <div className="bg-green-800/40 p-3 rounded">
                      <div className="flex items-center gap-2 text-white">
                        <Server size={16} />
                        <span className="font-semibold">Application Load Balancer</span>
                      </div>
                      <div className="text-green-200 text-xs mt-1">Routes traffic to services</div>
                    </div>
                    <div className="bg-green-800/40 p-3 rounded">
                      <div className="flex items-center gap-2 text-white">
                        <Shield size={16} />
                        <span className="font-semibold">NAT Gateway</span>
                      </div>
                      <div className="text-green-200 text-xs mt-1">Outbound internet access</div>
                    </div>
                  </div>
                </div>

                {/* Private Subnet */}
                <div className="bg-indigo-900/30 border border-indigo-500 rounded-lg p-4">
                  <h4 className="text-indigo-300 font-semibold mb-3 flex items-center gap-2">
                    <Lock size={18} />
                    Private Subnet
                  </h4>
                  <div className="space-y-3">
                    <div className="bg-indigo-800/40 p-3 rounded">
                      <div className="flex items-center gap-2 text-white">
                        <Package size={16} />
                        <span className="font-semibold">ECS Cluster</span>
                      </div>
                      <div className="text-indigo-200 text-xs mt-1">Docker containers</div>
                      <div className="mt-2 space-y-1">
                        <div className="text-xs bg-indigo-700/50 px-2 py-1 rounded">API Service</div>
                        <div className="text-xs bg-indigo-700/50 px-2 py-1 rounded">Auth Service</div>
                        <div className="text-xs bg-indigo-700/50 px-2 py-1 rounded">Frontend</div>
                      </div>
                    </div>
                    <div className="bg-indigo-800/40 p-3 rounded">
                      <div className="flex items-center gap-2 text-white">
                        <Database size={16} />
                        <span className="font-semibold">RDS PostgreSQL</span>
                      </div>
                      <div className="text-indigo-200 text-xs mt-1">Multi-AZ deployment</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Additional AWS Services */}
            <div className="grid grid-cols-4 gap-4">
              <div className="bg-yellow-900/30 border border-yellow-600 rounded p-3">
                <div className="text-yellow-300 font-semibold text-sm mb-1">S3 Bucket</div>
                <div className="text-yellow-200 text-xs">Static assets & backups</div>
              </div>
              <div className="bg-red-900/30 border border-red-600 rounded p-3">
                <div className="flex items-center gap-1 text-red-300 font-semibold text-sm mb-1">
                  <BarChart3 size={14} />
                  CloudWatch
                </div>
                <div className="text-red-200 text-xs">Logs & metrics</div>
              </div>
              <div className="bg-pink-900/30 border border-pink-600 rounded p-3">
                <div className="flex items-center gap-1 text-pink-300 font-semibold text-sm mb-1">
                  <Bell size={14} />
                  SNS/SES
                </div>
                <div className="text-pink-200 text-xs">Notifications</div>
              </div>
              <div className="bg-teal-900/30 border border-teal-600 rounded p-3">
                <div className="flex items-center gap-1 text-teal-300 font-semibold text-sm mb-1">
                  <Shield size={14} />
                  Secrets Manager
                </div>
                <div className="text-teal-200 text-xs">Credentials</div>
              </div>
            </div>
          </div>

          {/* Terraform */}
          <div className="bg-violet-900/30 border-2 border-violet-500 rounded-lg p-6">
            <div className="flex items-center gap-2 mb-4">
              <Package className="text-violet-400" size={24} />
              <h2 className="text-xl font-bold text-violet-300">Infrastructure as Code (Terraform)</h2>
            </div>
            <div className="grid grid-cols-4 gap-3">
              {['VPC Module', 'ECS Module', 'RDS Module', 'S3 Module'].map((module, i) => (
                <div key={i} className="bg-violet-800/50 p-3 rounded text-center">
                  <div className="text-white font-semibold text-sm">{module}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Key Features */}
          <div className="grid grid-cols-3 gap-4">
            <div className="bg-emerald-900/30 border border-emerald-500 rounded-lg p-4">
              <h3 className="text-emerald-300 font-semibold mb-2">Auto-Scaling</h3>
              <p className="text-emerald-200 text-sm">ECS tasks scale based on CPU/memory</p>
            </div>
            <div className="bg-cyan-900/30 border border-cyan-500 rounded-lg p-4">
              <h3 className="text-cyan-300 font-semibold mb-2">High Availability</h3>
              <p className="text-cyan-200 text-sm">Multi-AZ deployment with failover</p>
            </div>
            <div className="bg-amber-900/30 border border-amber-500 rounded-lg p-4">
              <h3 className="text-amber-300 font-semibold mb-2">Zero Downtime</h3>
              <p className="text-amber-200 text-sm">Blue-green deployment strategy</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}