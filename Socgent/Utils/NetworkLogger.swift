//
//  SocgentNetworkLogger.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Alamofire
import Foundation
import Moya
import Pulse

final class SocgentNetworkLogger: EventMonitor {
  let logger: NetworkLogger = NetworkLogger()
  
  func request(_ request: Request, didCreateTask task: URLSessionTask) {
    logger.logTaskCreated(task)
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    logger.logDataTask(dataTask, didReceive: data)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    logger.logTask(task, didFinishCollecting: metrics)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    logger.logTask(task, didCompleteWithError: error)
  }
}
