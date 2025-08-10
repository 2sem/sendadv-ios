import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.black // AppIcon 배경색에 맞게 hex값을 변경하세요
                .ignoresSafeArea()
            VStack {
                Image(.splashIcon) // Assets에 splashIcon 이름으로 이미지 추가 필요
                    .resizable()
                    .frame(width: 120, height: 120)
                    .cornerRadius(24)
                Text("보내봐 단체 문자")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}
