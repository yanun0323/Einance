import SwiftUI
import UIComponent

struct ProtoHomeView: View {
    @State private var selected: NavigationPath = .init()
    @State private var title: String? = nil
    @State private var debug: String = "-"
    @State private var accentColors: [Color] = [.cyan, Color(hex: "#2cc")]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                dashboard()
                    .padding(.bottom, 20)
                cardVeiw()
                Block(height: 100)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            header()
        }
        .onChange(of: selected) { v in
            debug = v.count.description
        }
    }
    
    @ViewBuilder
    private func header() -> some View {
        VStack {
            Spacer()
            HStack {
                Circle()
                    .frame(width: 80)
                    .foregroundLinearGradient(accentColors)
                    .shadow(radius: 5)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 45, weight: .light))
                            .foregroundColor(.white)
                    }
            }
            .font(.system(size: 20))
            .foregroundColor(.black.opacity(0.2))
        }
    }
    
    @ViewBuilder
    private func dashboard() -> some View {
        VStack(spacing: 5) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Summary")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundLinearGradient(accentColors)
                    HStack(alignment: .bottom) {
                        Text("12200")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundLinearGradient(accentColors)
                        Text("30000")
                            .font(.system(size: 24, weight: .medium))
                            .opacity(0.2)
                    }
                    .monospacedDigit()
                }
                Spacer()
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 30, weight: .light))
                    .scaleEffect(y: 1.3)
                    .opacity(0.2)
                    .padding(.trailing, 5)
            }
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundLinearGradient(accentColors)
                Block()
            }
            .background(Color.section)
            .frame(height: 10)
            .cornerRadius(5)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func cardVeiw() -> some View {
        ZStack {
            let radius: CGFloat = 30
            Rectangle()
                .foregroundColor(.transparent)
                .overlay {
                    VStack {
                        HStack {
                            Text("Food")
                                .font(.system(size: 40, weight: .medium))
                            Spacer()
                            Image(systemName: "pin.fill")
                                .rotationEffect(.degrees(45))
                                .font(.system(size: 20, weight: .medium))
                        }
                        HStack {
                            Text("5120")
                            Text("15000")
                                .opacity(0.2)
                            Spacer()
                        }
                        .font(.system(size: 40, weight: .medium, design: .rounded))
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding([.top, .horizontal], 30)
                    .monospacedDigit()
                }
                .backgroundLinearGradient(accentColors)
                .cornerRadius(radius)
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: radius)
                    .frame(height: 370)
                    .blendMode(.destinationOut)
                    .overlay {
                        VStack {
                            HStack {
                                Text("Today")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundLinearGradient(accentColors)
                                Spacer()
                            }
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(spacing: 10) {
                                    ForEach(0...30, id: \.self) { i in
                                        HStack {
//                                            Rectangle()
//                                                .foregroundLinearGradient(accentColors)
//                                                .frame(width: 5)
//                                                .padding(.trailing, 10)
                                            Text(i%2 == 0 ? "Breakfast" : "Dinner")
                                                .opacity(0.2)
                                            Spacer()
                                            Text("\(i)")
                                                .opacity(0.7)
                                                .font(.system(size: 22))
                                            Text("$")
                                                .opacity(0.2)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .font(.system(size: 20, weight: .medium))
                        .monospacedDigit()
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    }
            }
        }
        .compositingGroup()
    }
    
    @ViewBuilder
    private func detailLink(_ i: Int) -> some View {
        let date = Date(from: "20230501", .Numeric)?.AddDay(i).String("yyyy.MM.dd") ?? "-"
        NavigationLink {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(1...30, id: \.self) { r in
                        HStack {
                            Text(r%2 == 0 ? "Breakfast" : "Dinner")
                                .opacity(0.2)
                            Spacer()
                            Text("\(r)")
                                .opacity(0.8)
                                .font(.system(size: 22))
                            Text("$")
                                .opacity(0.2)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .onAppeared {
                withAnimation {
                    title = date
                }
            }
            .onDisappear {
                withAnimation {
                    title = nil
                }
            }
        } label: {
            HStack {
                Text(date)
                    .opacity(0.8)
                    .font(.system(size: 25))
                Spacer()
                Text("1233")
                    .opacity(0.2)
                Text("$")
                    .opacity(0.2)
            }
            .monospacedDigit()
            .foregroundColor(.primary)
        }
    }
    
}

struct ProtoHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProtoHomeView()
    }
}
