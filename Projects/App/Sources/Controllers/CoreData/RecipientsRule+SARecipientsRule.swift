
extension RecipientsRule {
    convenience init(from coreDataRule: SARecipientsRule) {
        let title = coreDataRule.title
        let enabled = coreDataRule.enabled
        
        self.init(title: title, enabled: enabled)
    }
}
