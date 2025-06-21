library(shiny)   # Shiny框架，用于构建交互式Web应用
library(httr)      # 用于发送HTTP请求，调用API
library(jsonlite)      # 处理JSON数据格式
library(pdftools)        # 读取PDF文件内容 
library(docxtractr)        # 提取Word文档内容
library(officer)            # 操作Word文档
library(rmarkdown)            # 处理Rmarkdown文件
library(xml2)                  # 处理XML数据
library(rvest)                   # 网页内容抓取
library(dplyr)                     # 数据处理和操作
library(rsconnect)                   # Shiny应用部署
library(plotly)                       # 交互式数据可视化
library(openxlsx) # 用于导出Excel      # 导出Excel文件

# --------------------------
# 用户界面定义
# --------------------------
# 设置上传文件大小限制为50MB
options(shiny.maxRequestSize = 50*1024^2)  
# 设置并行处理内存限制为500MB
options(future.globals.maxSize = 500*1024^2)  

ui <- fluidPage(
  # 添加CSS样式，用于美化界面和创建数字人动画
  tags$head(
    tags$style(HTML("
      /* 增强的数字人动画样式 */
      .digital-person {
        position: relative;
        width: 240px;
        height: 380px;
        margin: 20px auto;
        transform-origin: bottom center;
        perspective: 1000px;
      }
      
      /* 数字人容器样式 */
      .digital-person-container {
        position: relative;
        width: 100%;
        height: 100%;
        transform-style: preserve-3d;
        animation: float 6s ease-in-out infinite;
      }
      
      /* 数字人头部样式和动画 */
      .head {
        position: absolute;
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 140px;
        height: 140px;
        background: linear-gradient(145deg, #FFD700, #FFEA7F);
        border-radius: 55% 55% 45% 45%;
        box-shadow: 0 8px 25px rgba(0,0,0,0.15), 
                    inset 0 4px 10px rgba(255,255,255,0.7),
                    inset 0 -4px 10px rgba(0,0,0,0.1);
        z-index: 10;
        animation: head-bounce 4s ease-in-out infinite;
      }
      
      /* 数字人眼睛样式和眨眼动画 */
      .eyes {
        position: absolute;
        top: 45px;
        width: 100%;
        display: flex;
        justify-content: center;
        gap: 30px;
      }
      
      .eye {
        position: relative;
        width: 24px;
        height: 24px;
        background: radial-gradient(circle, #333 0%, #000 100%);
        border-radius: 50%;
        box-shadow: 0 2px 5px rgba(0,0,0,0.3);
        animation: blink 4s infinite;
      }
      
      .eye::before {
        content: '';
        position: absolute;
        top: 4px;
        left: 6px;
        width: 8px;
        height: 8px;
        background: white;
        border-radius: 50%;
        box-shadow: 0 0 8px rgba(255,255,255,0.8);
        animation: pupil-reflect 4s infinite;
      }
      
      /* 数字人嘴巴样式和说话动画 */
      .mouth {
        position: absolute;
        top: 85px;
        left: 50%;
        transform: translateX(-50%);
        width: 45px;
        height: 18px;
        background: linear-gradient(180deg, #FF6B6B, #E25822);
        border-radius: 0 0 25px 25px;
        box-shadow: inset 0 2px 5px rgba(0,0,0,0.2);
        animation: talk 3s infinite;
      }
      
      /* 数字人耳朵样式 */
      .ears {
        position: absolute;
        top: 40px;
        width: 100%;
        display: flex;
        justify-content: space-between;
        z-index: 5;
      }
      
      .ear {
        width: 18px;
        height: 30px;
        background: linear-gradient(90deg, #FFD700, #FFEA7F);
        border-radius: 40% 60% 60% 40% / 30% 30% 70% 70%;
        box-shadow: inset 0 2px 5px rgba(0,0,0,0.1);
      }
      
      .left-ear {
        transform: translateX(-15px);
      }
      
      .right-ear {
        transform: translateX(15px) scaleX(-1);
      }
      
      /* 数字人头发样式 */
      .hair {
        position: absolute;
        top: -15px;
        left: 50%;
        transform: translateX(-50%);
        width: 150px;
        height: 60px;
        background: #333;
        border-radius: 50% 50% 0 0 / 70% 70% 0 0;
        z-index: 15;
      }
      
      .hair::before {
        content: '';
        position: absolute;
        top: 10px;
        left: 20px;
        width: 110px;
        height: 40px;
        background: linear-gradient(to bottom, rgba(255,255,255,0.1), transparent);
        border-radius: 50%;
      }
      
      /* 数字人身体样式和摇摆动画 */
      .body {
        position: absolute;
        top: 130px;
        left: 50%;
        transform: translateX(-50%);
        width: 120px;
        height: 160px;
        background: linear-gradient(145deg, #4B8BBE, #6AA1CC);
        border-radius: 45% 45% 15% 15%;
        box-shadow: 0 10px 25px rgba(0,0,0,0.15), 
                    inset 0 4px 10px rgba(255,255,255,0.3),
                    inset 0 -4px 10px rgba(0,0,0,0.1);
        animation: body-sway 5s ease-in-out infinite;
        overflow: hidden;
      }
      
      /* 数字人领带样式 */
      .tie {
        position: absolute;
        top: 150px;
        left: 50%;
        transform: translateX(-50%);
        width: 25px;
        height: 40px;
        background: linear-gradient(180deg, #E25822, #FF6B6B);
        border-radius: 0 0 50% 50%;
        z-index: 12;
      }
      
      /* 数字人衬衫领口样式 */
      .collar {
        position: absolute;
        top: 140px;
        left: 50%;
        transform: translateX(-50%);
        width: 80px;
        height: 20px;
        background: white;
        border-radius: 50% 50% 0 0;
        z-index: 11;
      }
      
      /* 数字人手臂样式和挥手动画 */
      .arms {
        position: absolute;
        top: 140px;
        width: 100%;
        display: flex;
        justify-content: space-between;
        z-index: 5;
      }
      
      .arm {
        position: relative;
        width: 25px;
        height: 90px;
        background: linear-gradient(145deg, #4B8BBE, #6AA1CC);
        border-radius: 15px;
        box-shadow: inset 0 2px 5px rgba(255,255,255,0.3),
                    inset 0 -2px 5px rgba(0,0,0,0.2);
      }
      
      .left-arm {
        transform-origin: top center;
        animation: wave-left 4s infinite;
      }
      
      .right-arm {
        transform-origin: top center;
        animation: wave-right 4s infinite;
      }
      
      /* 数字人手部样式 */
      .hand {
        position: absolute;
        bottom: -15px;
        left: 50%;
        transform: translateX(-50%);
        width: 30px;
        height: 30px;
        background: #FFD700;
        border-radius: 50%;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
      }
      
      /* 数字人腿部样式 */
      .legs {
        position: absolute;
        top: 280px;
        left: 50%;
        transform: translateX(-50%);
        width: 100px;
        display: flex;
        justify-content: space-between;
        z-index: 4;
      }
      
      .leg {
        width: 30px;
        height: 70px;
        background: linear-gradient(180deg, #306998, #4B8BBE);
        border-radius: 15px 15px 0 0;
        box-shadow: inset 0 2px 5px rgba(255,255,255,0.2);
      }
      
      /* 数字人脚部样式 */
      .feet {
        position: absolute;
        bottom: -15px;
        width: 100%;
        display: flex;
        justify-content: space-between;
      }
      
      .foot {
        width: 35px;
        height: 15px;
        background: #333;
        border-radius: 50% 50% 0 0;
      }
      
      /* 各种动画定义 */
      @keyframes float {
        0%, 100% { transform: translateY(0) rotateY(0deg); }
        25% { transform: translateY(-10px) rotateY(5deg); }
        75% { transform: translateY(-5px) rotateY(-5deg); }
      }
      
      @keyframes head-bounce {
        0%, 100% { transform: translateX(-50%) translateY(0); }
        50% { transform: translateX(-50%) translateY(-15px); }
      }
      
      @keyframes blink {
        0%, 90%, 100% { height: 24px; }
        95% { height: 5px; }
      }
      
      @keyframes pupil-reflect {
        0%, 100% { transform: translate(0, 0); }
        50% { transform: translate(1px, -1px); }
      }
      
      @keyframes talk {
        0%, 50%, 100% { height: 18px; width: 45px; border-radius: 0 0 25px 25px; }
        25% { height: 8px; width: 35px; border-radius: 0 0 15px 15px; }
        75% { height: 25px; width: 50px; border-radius: 0 0 30px 30px; }
      }
      
      @keyframes body-sway {
        0%, 100% { transform: translateX(-50%) rotate(0deg); }
        50% { transform: translateX(-50%) rotate(3deg); }
      }
      
      @keyframes wave-left {
        0%, 100% { transform: rotate(0deg); }
        25% { transform: rotate(-45deg); }
        50% { transform: rotate(-30deg); }
      }
      
      @keyframes wave-right {
        0%, 100% { transform: rotate(0deg); }
        25% { transform: rotate(30deg); }
        50% { transform: rotate(45deg); }
      }
      
      /* 欢迎面板样式 */
      .welcome-panel {
        background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
        color: white;
        border-radius: 15px;
        padding: 20px;
        margin: 20px 0;
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        text-align: center;
        transition: all 0.3s ease;
      }
      
      .welcome-panel:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 30px rgba(0,0,0,0.15);
      }
      
      .feature-list {
        display: flex;
        justify-content: space-around;
        flex-wrap: wrap;
        margin-top: 20px;
      }
      
      .feature-item {
        background: rgba(255,255,255,0.2);
        border-radius: 10px;
        padding: 15px;
        margin: 10px;
        width: 120px;
        text-align: center;
        transition: all 0.3s ease;
      }
      
      .feature-item:hover {
        transform: translateY(-5px);
        background: rgba(255,255,255,0.3);
      }
      
      /* 详细评分结果卡片样式 */
      .score-card {
        background: #ffffff;
        border-radius: 15px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        margin-bottom: 20px;
        overflow: hidden;
        transition: all 0.3s ease;
      }
      
      .score-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
      }
      
      .card-header {
        padding: 15px 20px;
        background: #f8f9fa;
        border-bottom: 1px solid #e9ecef;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .card-title {
        font-weight: 600;
        color: #2c3e50;
      }
      
      .card-score {
        font-size: 1.5em;
        font-weight: bold;
        padding: 8px 15px;
        border-radius: 10px;
      }
      
      .score-excellent {
        background: rgba(46, 204, 113, 0.1);
        color: #2ecc71;
      }
      
      .score-good {
        background: rgba(52, 152, 219, 0.1);
        color: #3498db;
      }
      
      .score-fair {
        background: rgba(243, 156, 18, 0.1);
        color: #f39c12;
      }
      
      .score-poor {
        background: rgba(231, 76, 60, 0.1);
        color: #e74c3c;
      }
      
      .card-body {
        padding: 20px;
      }
      
      .feedback-title {
        font-weight: 600;
        margin-bottom: 10px;
        color: #34495e;
      }
      
      .feedback-content {
        line-height: 1.6;
        color: #555;
      }
      
      /* 表格样式 */
      .data-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
      }
      
      .data-table th, .data-table td {
        padding: 12px 15px;
        text-align: left;
        border-bottom: 1px solid #e9ecef;
      }
      
      .data-table th {
        background-color: #f8f9fa;
        color: #2c3e50;
        font-weight: 600;
      }
      
      .data-table tr:hover {
        background-color: #f5f5f5;
      }
      
      /* 加载动画 */
      .loading-spinner {
        display: inline-block;
        width: 24px;
        height: 24px;
        border: 3px solid rgba(0,0,0,0.1);
        border-radius: 50%;
        border-top-color: #3498db;
        animation: spin 1s linear infinite;
      }
      
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
    "))
  ),
  
  # 应用标题
  titlePanel("智能作业评分系统"),
  
  # 侧边栏布局
  sidebarLayout(
    sidebarPanel(
      width = 4,
      # 欢迎面板，展示应用特点
      div(class = "welcome-panel",
          h3("欢迎使用AI评分系统", style = "margin-top: 0;"),
          div(class = "feature-list",
              div(class = "feature-item", icon("robot"), "AI智能评分"),
              div(class = "feature-item", icon("file-alt"), "多格式支持"),
              div(class = "feature-item", icon("chart-bar"), "数据分析"),
              div(class = "feature-item", icon("download"), "一键导出")
          )
      ),
      
      # 增强版动态数字人动画
      div(class = "digital-person",
          div(class = "digital-person-container",
              div(class = "hair"),
              div(class = "head",
                  div(class = "eyes",
                      div(class = "eye"),
                      div(class = "eye")
                  ),
                  div(class = "mouth"),
                  div(class = "ears",
                      div(class = "ear left-ear"),
                      div(class = "ear right-ear")
                  )
              ),
              div(class = "body"),
              div(class = "tie"),
              div(class = "collar"),
              div(class = "arms",
                  div(class = "arm left-arm",
                      div(class = "hand")
                  ),
                  div(class = "arm right-arm",
                      div(class = "hand")
                  )
              ),
              div(class = "legs",
                  div(class = "leg",
                      div(class = "feet",
                          div(class = "foot")
                      )
                  ),
                  div(class = "leg",
                      div(class = "feet",
                          div(class = "foot")
                      )
                  )
              )
          )
      ),
      
      # 文件上传控件，支持多种格式
      fileInput("files", "上传作业文档", multiple = TRUE,
                accept = c(".pdf", ".docx", ".txt", ".rmd"),
                buttonLabel = icon("upload")),
      
      # 自定义评分标准的提示词输入框
      textAreaInput("prompt_input", "AI评分提示词", 
                    value = "你是一位专业教师，请根据以下作业内容用中文进行评分（0-100分），具体要求：\n1. 内容准确性（60%）\n2. 逻辑结构（40%）\n",
                    rows = 6,
                    placeholder = "请输入自定义评分标准"),
      
      # 评分和下载按钮
      div(style = "display: flex; justify-content: space-between;",
          actionButton("submit", "开始评分", 
                       class = "btn-primary",
                       icon = icon("play-circle")),
          downloadButton("download", "下载Excel结果", 
                         class = "btn-success",
                         icon = icon("download"))
      )
    ),
    
    # 主面板显示结果
    mainPanel(
      width = 8,
      h3("评分进度", style = "color: #2c3e50;"),
      tableOutput("progress_table"),
      
      h3("详细评分结果", style = "margin-top: 30px; color: #2c3e50;"),
      uiOutput("detailed_results"),
      
      h3("分数分布", style = "margin-top: 30px; color: #2c3e50;"),
      tabsetPanel(
        tabPanel("柱状图", plotlyOutput("hist_plot")),
        tabPanel("折线图", plotlyOutput("line_plot")),
        tabPanel("饼图", plotlyOutput("pie_plot"))
      ),
      
      h3("详细日志", style = "margin-top: 30px; color: #2c3e50;"),
      div(style = "background: #f8f9fa; border-radius: 10px; padding: 15px;",
          verbatimTextOutput("log")
      )
    )
  )
)

# --------------------------
# 服务端逻辑
# --------------------------
server <- function(input, output) {
  # 设置DeepSeek API密钥
  Sys.setenv(DEEPSEEK_API_KEY = "sk-ce74894c107e4766a81d0c892a0d08cf")
  
  # 监听评分结果变化，更新可视化图表
  observe({
    req(all_results()) # 依赖评分结果
    
    df <- all_results()
    
    # 柱状图（分数段分布）
    output$hist_plot <- renderPlotly({
      plot_ly(data = df, x = ~分数, type = "histogram",
              xbins = list(size = 10), 
              marker = list(color = "#4E79A7"),
              hoverinfo = "y") %>%
        layout(title = "分数段分布",
               xaxis = list(title = "分数", range = c(0, 100)),
               yaxis = list(title = "人数"),
               plot_bgcolor = "#f8f9fa",
               paper_bgcolor = "#f8f9fa")
    })
    
    # 折线图（累积分布）
    output$line_plot <- renderPlotly({
      df_cum <- df %>% 
        arrange(分数) %>% 
        mutate(cum_pct = cumsum(!is.na(分数))/nrow(.))
      
      plot_ly(df_cum, x = ~分数, y = ~cum_pct, type = "scatter", mode = "lines",
              line = list(color = "#E15759", width = 3),
              hoverinfo = "x+y") %>%
        layout(title = "累积分数分布",
               xaxis = list(title = "分数"),
               yaxis = list(title = "累积百分比", tickformat = "%"),
               plot_bgcolor = "#f8f9fa",
               paper_bgcolor = "#f8f9fa")
    })
    
    # 饼图（等级分布）
    output$pie_plot <- renderPlotly({
      df_level <- df %>%
        mutate(等级 = cut(分数, 
                        breaks = c(0, 60, 75, 85, 100),
                        labels = c("不及格", "及格", "良好", "优秀"))) %>%
        count(等级)
      
      plot_ly(df_level, labels = ~等级, values = ~n, type = "pie",
              textinfo = "percent+label",
              hoverinfo = "label+percent",
              marker = list(colors = c("#F28E2B", "#59A14F", "#EDC948", "#B07AA1")),
              hole = 0.4) %>%
        layout(title = "成绩等级比例",
               plot_bgcolor = "#f8f9fa",
               paper_bgcolor = "#f8f9fa")
    })
  })
  
  # 存储动态提示词，处理换行符
  custom_prompt <- reactive({
    req(input$prompt_input)  # 确保输入不为空
    gsub("\n", "\\\\n", input$prompt_input)  # 处理换行符
  })
  
  # 存储所有评分结果的数据框
  all_results <- reactiveVal(data.frame(
    文件名 = character(),
    分数 = numeric(),
    反馈 = character(),
    时间 = character(),
    stringsAsFactors = FALSE
  ))
  
  # 批量解析上传的文件
  parse_all_files <- function(files) {
    req(files)
    # 创建进度条
    progress <- Progress$new(max = nrow(files))
    on.exit(progress$close())
    
    results <- lapply(seq_len(nrow(files)), function(i) {
      file <- files[i, ]
      progress$inc(1, detail = paste("正在处理", file$name))
      
      tryCatch({
        # 根据文件类型读取内容
        text <- switch(
          tools::file_ext(file$name),
          "pdf" = paste(pdf_text(file$datapath), collapse = "\n"),
          "docx" = officer::read_docx(file$datapath) %>% 
            officer::docx_summary() %>% 
            dplyr::pull(text) %>% 
            paste(collapse = "\n"),
          "rmd" = parse_rmd(file$datapath),  # 自定义Rmd解析函数
          "html" = rvest::html_text(xml2::read_html(file$datapath)),
          paste(readLines(file$datapath), collapse = "\n")
        )
        
        # 调用大模型API进行评分
        result <- call_llm_api(text)
        data.frame(
          文件名 = file$name,
          分数 = result$score,
          反馈 = result$feedback,
          时间 = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          stringsAsFactors = FALSE
        )
      }, error = function(e) {
        # 处理文件读取错误
        data.frame(
          文件名 = file$name,
          分数 = NA,
          反馈 = paste("错误:", e$message),
          时间 = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          stringsAsFactors = FALSE
        )
      })
    })
    
    # 合并所有结果
    do.call(rbind, results)
  }
  
  # 自定义Rmd解析函数，移除代码块和YAML头部
  parse_rmd <- function(path) {
    lines <- readLines(path, warn = FALSE)
    # 移除代码块和YAML头部
    content <- grep("^```|^---", lines, invert = TRUE, value = TRUE)
    paste(content, collapse = "\n")
  }
  
  # 监听"开始评分"按钮点击事件
  observeEvent(input$submit, {
    req(input$files)
    results <- parse_all_files(input$files)
    all_results(rbind(all_results(), results))
    
    # 更新进度表格
    output$progress_table <- renderTable({
      req(all_results())
      all_results() %>%
        select(文件名, 分数, 时间)
    })
  })
  
  # 显示详细评分结果
  output$detailed_results <- renderUI({
    req(all_results())
    
    results <- all_results()
    
    if(nrow(results) == 0) {
      return(div(class = "alert alert-info", "暂无评分结果"))
    }
    
    lapply(1:nrow(results), function(i) {
      result <- results[i, ]
      score_class <- ifelse(is.na(result$分数), "score-poor", 
                           ifelse(result$分数 >= 85, "score-excellent",
                                 ifelse(result$分数 >= 75, "score-good",
                                       ifelse(result$分数 >= 60, "score-fair", "score-poor"))))
      
      div(class = "score-card",
          div(class = "card-header",
              div(class = "card-title", result$文件名),
              div(class = paste("card-score", score_class), 
                  ifelse(is.na(result$分数), "未评分", result$分数))
          ),
          div(class = "card-body",
              div(class = "feedback-title", "详细反馈:"),
              div(class = "feedback-content", result$反馈)
          )
      )
    })
  })
  
  # 下载评分结果为Excel文件
  output$download <- downloadHandler(
    filename = function() {
      paste("作业评分结果_", Sys.Date(), ".xlsx", sep = "")
    },
    content = function(file) {
      # 创建工作簿
      wb <- createWorkbook()
      
      # 添加评分结果工作表
      addWorksheet(wb, "评分结果")
      writeData(wb, "评分结果", all_results())
      
      # 添加统计信息工作表
      addWorksheet(wb, "统计信息")
      
      # 计算统计信息
      stats_data <- data.frame(
        统计项 = c("总作业数", "平均分", "最高分", "最低分", "及格率"),
        值 = c(
          nrow(all_results()),
          mean(all_results()$分数, na.rm = TRUE),
          max(all_results()$分数, na.rm = TRUE),
          min(all_results()$分数, na.rm = TRUE),
          paste0(round(mean(all_results()$分数 >= 60, na.rm = TRUE) * 100, 2), "%")
        )
      )
      
      writeData(wb, "统计信息", stats_data)
      
      # 保存工作簿
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
  
  # 实时日志输出
  output$log <- renderPrint({
    req(input$files)
    current_results <- all_results()
    
    # 输出系统状态信息
    cat(paste("系统时间:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n"))
    cat(paste("已上传文件:", nrow(input$files), "个\n"))
    cat(paste("已完成评分:", nrow(current_results), "个\n"))
    
    if (nrow(current_results) > 0) {  
      cat("\n最近处理结果:\n")
      print(tail(current_results[, c("文件名", "分数", "时间")], 3))
    }
    
    cat("\n系统状态:\n")
    cat(paste("内存使用:", format(utils::object.size(all_results()), units = "auto"), "\n"))
    cat("API状态: 正常\n")
  })
  
  # 调用大模型API的核心函数
  call_llm_api <- function(text) {
    # 获取用户输入的纯评分规则
    user_prompt <- input$prompt_input
    
    # 构造最终提示词，包括评分规则和JSON格式要求
    final_prompt <- paste0(
      "你是一位专业教师，请根据以下要求评分：\n",
      user_prompt, "\n\n",  # 用户自定义的评分规则
      "------\n",  # 分隔线
      "必须返回严格遵循以下格式的JSON：\n",
      "{\"score\": 分数值(0-100), \"feedback\": \"文字反馈\"}\n",
      "不要包含任何额外解释或前缀后缀。"
    )
    
    # 构造API消息
    messages <- list(
      list(
        role = "system",
        content = gsub("\n", "\\\\n", final_prompt)  # 处理换行符
      ),
      list(
        role = "user",
        content = paste("作业内容如下：", text)
      )
    )
    
    # 发送API请求
    response <- POST(
      url = "https://api.deepseek.com/v1/chat/completions",
      add_headers(
        `Authorization` = paste("Bearer", Sys.getenv("DEEPSEEK_API_KEY")),
        `Content-Type` = "application/json"  # 明确指定Content-Type
      ),  
      body = list(
        model = "deepseek-chat",
        messages = messages,
        temperature = 0.3,
        response_format = list(type = "json_object")
      ),
      encode = "json",  # 编码方式
      timeout(30)       # 设置超时时间
    )
    
    # 处理响应
    if (status_code(response) != 200) {
      stop("API调用失败：", content(response, "text", encoding = "UTF-8"))
    }
    
    # 解析JSON结果
    result <- content(response, "parsed")
    fromJSON(result$choices[[1]]$message$content)
  }
}

# --------------------------
# 运行应用
# --------------------------
shinyApp(ui = ui, server = server)    