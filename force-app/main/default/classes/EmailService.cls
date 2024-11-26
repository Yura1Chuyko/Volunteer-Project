public with sharing class EmailService {
    public static String sendDonationReceipt(String recipientEmail, 
                                           String transactionId,
                                           String fundraisingName, 
                                           String paymentMethod,
                                           String currencySign, 
                                           String amount, 
                                           String paymentDate) {
        return '<!DOCTYPE html>' +
                            '<html lang="en">' +
                            '<head>' +
                            '<meta charset="UTF-8">' +
                            '<meta name="viewport" content="width=device-width, initial-scale=1.0">' +
                            '<title>Donation Receipt</title>' +
                            '</head>' +
                            '<body style="margin: 0; padding: 20px; font-family: Arial, sans-serif; background-color: #f5f7ff;">' +
                            '<div style="max-width: 600px; margin: auto; background: white; border-radius: 8px; box-shadow: 0 2px 15px rgba(0,0,0,0.1);">' +
                            '<div style="background: linear-gradient(135deg, #4f46e5, #7c3aed); padding: 40px 20px; text-align: center; color: white; border-radius: 8px 8px 0 0;">' +
                            '<h1 style="font-size: 24px; margin: 0;">Thank You for Your Payment!</h1>' +
                            '<p style="margin: 10px 0 0;">Your transaction has been completed successfully</p>' +
                            '</div>' +
                            '<div style="padding: 40px 30px;">' +
                            '<div style="margin-bottom: 20px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;">' +
                            '<p style="margin: 0; color: #64748b; font-size: 14px;">Transaction ID</p>' +
                            '<p style="margin: 4px 0 0; color: #1e293b; font-size: 15px; font-weight: 600; font-family: monospace;">' + transactionId + '</p>' +
                            '</div>' +
                            '<div style="margin-bottom: 20px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;">' +
                            '<p style="margin: 0; color: #64748b; font-size: 14px;">Fundraising</p>' +
                            '<p style="margin: 4px 0 0; color: #1e293b; font-size: 15px; font-weight: 600;">' + fundraisingName + '</p>' +
                            '</div>' +
                            '<div style="margin-bottom: 20px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;">' +
                            '<p style="margin: 0; color: #64748b; font-size: 14px;">Payment Method</p>' +
                            '<p style="margin: 4px 0 0; color: #1e293b; font-size: 15px; font-weight: 600;">' + paymentMethod + '</p>' +
                            '</div>' +
                            '<div style="margin-bottom: 20px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;">' +
                            '<p style="margin: 0; color: #64748b; font-size: 14px;">Total Amount</p>' +
                            '<p style="margin: 4px 0 0; color: #1e293b; font-size: 15px; font-weight: 600;">' + currencySign + amount + '</p>' +
                            '</div>' +
                            '<div style="margin-bottom: 20px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px;">' +
                            '<p style="margin: 0; color: #64748b; font-size: 14px;">Payment Date</p>' +
                            '<p style="margin: 4px 0 0; color: #1e293b; font-size: 15px; font-weight: 600;">' + paymentDate + '</p>' +
                            '</div>' +
                            '</div>' +
                            '<div style="text-align: center; padding: 30px 20px; border-top: 1px solid #e2e8f0;">' +
                            '<p style="color: #64748b; font-size: 14px; margin-bottom: 10px;">If you have any questions, please contact our support team</p>' +
                            '<a href="mailto:support@example.com" style="color: #4f46e5; text-decoration: none; font-size: 14px; font-weight: 500;">support@example.com</a>' +
                            '</div>' +
                            '</div>' +
                            '</body>' +
                            '</html>';
    
    }
}