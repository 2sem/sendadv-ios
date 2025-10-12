import SwiftUI
import SwiftData

struct SplashScreen: View {
    @Binding var isDone: Bool
    @StateObject private var migrationManager = DataMigrationManager()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(.splashIcon)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .cornerRadius(24)
                
                Text("App Title".localized())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 마이그레이션 상태에 따른 표시
                switch migrationManager.migrationStatus {
                case .checking:
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text(migrationManager.currentStep)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                case .migrating:
                    VStack(spacing: 16) {
                        ProgressView(value: migrationManager.migrationProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(width: 200)
                        
                        Text(migrationManager.currentStep)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                case .completed:
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text(migrationManager.currentStep)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                case .failed(let error):
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text("Migration Failed".localized())
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Text(error.localizedDescription)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                case .idle:
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("Initializing app...".localized())
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .onAppear {
            startMigrationProcess()
        }
    }
    
    private func startMigrationProcess() {
        Task {
            // 마이그레이션 수행
            _ = await migrationManager.checkAndMigrateIfNeeded()
            
            // 마이그레이션 완료 후 App에 알림
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isDone = true
                }
            }
        }
    }
}

#Preview {
    SplashScreen(isDone: .constant(false))
}

