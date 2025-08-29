//
//  EmptyChartAllPage.swift
//  portos
//
//  Created by James Silaban on 28/08/25.
//

import SwiftUI

struct EmptyAssetAllocationChart: View {
    var body: some View {
        VStack(spacing: 16) {
            // Chart placeholder area
            VStack(spacing: 12) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.greyApp)
                
                Text("no_asset_allocation".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.greyApp)
            }
            
            
            // Text content
            VStack(spacing: 8) {
                Text("start_building_portfolio_short".localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.secondaryApp)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 241)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
}
